`timescale 1ns/1fs

// -----------------------------------------------------------------
// Oscillator bridge core
// Instantiate to drive and sample a single-ended or differential 
// clock signal
// -----------------------------------------------------------------

// Please note that this model uses the cds_rnm_pkg, which is installed in the Cadence Xcelium tool
// For non-Cadence simulators, please replace this with the equivalent RNM package 

module osc_bridge_core import cds_rnm_pkg::*; (
  inout  wreal4state osc_clk,
  output wreal4state osc_clk_p,
  output wreal4state osc_clk_n
  // ,
  // input wreal4state freq_in,
  // output wreal4state freq_out
  );
  
  parameter diff_sel = 0;
  parameter passive = 0;
  // ----- Registers driven by UVM Driver ----
  // -- sampler control
  real delay_in;
  bit [31:0] duration_in;
  bit sampling_do;
  // ----- Registers read by UVM Monitor ----
  bit sampling_done;
  real ampl_out;
  real bias_out;
  real freq_out;
  
  // -- oscillator control
  real ampl_in;
  real bias_in;
  real freq_in;
  reg enable;
  
  reg driver_on;   // drive from top/SV/e

  initial driver_on = 1;

  //Driver block
  clk_generator driver(.enable(enable), .osc_clk(osc_clk), .ampl_in(ampl_in), .bias_in(bias_in), 
    .freq_in(freq_in));
  
  //Sampler block
  clk_detector #(.diff_sel(diff_sel), .passive(passive)) sampler(.osc_clk(osc_clk), .osc_clk_p(osc_clk_p), 
    .osc_clk_n(osc_clk_n), .delay(delay_in), .duration(duration_in), .sampling_do(sampling_do), 
    .sampling_done(sampling_done), .ampl(ampl_out), .bias(bias_out), .freq(freq_out)); 
    
endmodule 


//Clock generator
//This uses the ampl_in, bias_in and freq_in inputs to generate the single-ended osc_clk output

// Please note that this model uses the cds_rnm_pkg, which is installed in the Cadence Xcelium tool
// For non-Cadence simulators, please replace this with the equivalent RNM package 

module clk_generator import cds_rnm_pkg::*; (
  output wreal4state osc_clk,
  input wire enable,
  input  wreal4state ampl_in,
  input  wreal4state bias_in,
  input  wreal4state freq_in         //Unit: Hz
  );
  
  // UVM for message reporting
  import uvm_pkg::*;
  `include "uvm_ms.vdmsh"

  reg  control_good;
  real v_osc;
  real out_period;  // Output clock period, in simulation timescale units (ns)

  initial begin
    control_good = 0;
  end

  // control parameters for sampling period
  // ----------------------------
  always @(freq_in, ampl_in, enable) begin
    if (enable == 1 && freq_in != 0 && ampl_in != 0) begin
      out_period = 1e9 / freq_in;
      control_good = 1;
      `uvm_ms_info("FREQ_UPDATE",$sformatf("Bridge is generating osc_clk with freq=%e Hz period=%e ns", freq_in, out_period),UVM_MEDIUM)
    end
    else begin
      out_period = 0;
      control_good = 0;
    end
  end

  always begin
    if(out_period != 0) begin
      v_osc = ampl_in;
      #(out_period/2.0);
      v_osc = -ampl_in;
      #(out_period/2.0);
    end
    else begin
      v_osc = 0;
      @(out_period);
    end
  end

  // Analog oscillator
  // ----------------------------
  
  assign osc_clk = control_good ? (bias_in + (enable * v_osc)) : `wrealZState;
  
endmodule

//Clock detector
//This can be configured in active or passive mode using the "passive" parameter, and in single-ended or
//differential mode using the "diff_sel" parameter
//This analyzes the osc_clk signal (or osc_clk_p and osc_clk_n signals when configured in differential
//mode using diff_sel=1) to extract its/their frequency, amplitude and DC bias. These are driven onto
//the ampl_out, bias_out and freq_out nets. When sampling is finished the "sampling_done" port is pulsed
//The detector can be triggered in two ways:
//1.  By pulsing the sampling_do signal (typically driven by a UVC driver when the attached UVC is in
//    active mode -- parameter passive=0)
//2.  Internally through the clk_observer block, which will monitor the clock signal(s) and automatically 
//    detect changes in frequency, amplitude or bias and trigger a "change_observed" event to inform the
//    detector module

// Please note that this model uses the cds_rnm_pkg, which is installed in the Cadence Xcelium tool
// For non-Cadence simulators, please replace this with the equivalent RNM package 

module clk_detector import cds_rnm_pkg::*; (
  input wreal4state osc_clk,
  input wreal4state osc_clk_p,
  input wreal4state osc_clk_n,
  input wreal4state delay,
  input wire [31:0] duration,
  input wire sampling_do,
  output reg sampling_done,
  output wreal4state ampl,
  output wreal4state bias,
  output wreal4state freq
  );

  // UVM for message reporting
  import uvm_pkg::*;
  `include "uvm_ms.vdmsh"

  parameter diff_sel = 0;
  parameter passive = 0;
	
  parameter real vth = 0.2;
  parameter real timeout_ns = 160;
  parameter real t_tol = 0.01e-9;
  parameter real tsamp_nom_ns = 0.1;  //Nominal sampling time for amplitude/bias calculation. 
                                      //Will be updated when period calculation arrives
  
  real  Vclk_p;
  real  Vclk_n;
	real period;

	// Registers
  real  ampl_r;
  reg   clk;
  reg   start_clk_period_calc = 0;
  reg   start_clk_ampl_bias_calc = 0;
  reg [31:0] duration_int;
  real delay_int;
  
	// temporaries 
  real  min_a;
  real  max_a;
  real  last_sig;
  real  period_p_r, period_n_r;
  real  clk_p_hi_time, clk_n_hi_time;   // Positive half-cycle time
  real  clk_p_lo_time, clk_n_lo_time;   // Negative half-cycle time
  real  clk_p_hi_start, clk_n_hi_start; // Start times for positive half-cycle
  real  clk_p_lo_start, clk_n_lo_start; // Start times for negative half-cycle
  real  tsamp_p_ns = tsamp_nom_ns;
  real  tsamp_n_ns = tsamp_nom_ns;
  real  vsamp_p [2:0];
  real  vsamp_n [2:0];
  real  dt;
  real  tmp;
  real  max_amp_p, max_amp_n;
  real  min_amp_p, min_amp_n;
  reg   samp_clk_p = 0, samp_clk_n = 0;
  integer sample_counter_p, sample_counter_n, duration_counter;

  assign ampl = (diff_sel == 0) ? ((max_amp_p - min_amp_p)/2.0) : ((max_amp_p - min_amp_p + max_amp_n - min_amp_n)/4.0);
  assign bias = (diff_sel == 0) ? ((min_amp_p + max_amp_p)/2.0) : ((min_amp_p + min_amp_n + max_amp_p + max_amp_n)/4.0);
  assign period = (diff_sel == 0) ? period_p_r/1s : ((period_p_r + period_n_r)/(2.0*1s)); // period in s
  assign freq = (period == 0 ? 0 : 1/period); //Frequency in Hz

  assign duration_int = passive ? 32'd64 : duration; //Default duration is the upper end of the typical duration range
  assign delay_int = passive ? 1.1 : delay; //Default delay is the upper end of the typical delay range
  wire duration_complete;
  assign duration_complete = (duration_counter >= duration_int);
  
  assign clk_p_tracker = diff_sel == 0 ? (osc_clk > vth) : (osc_clk_p > vth);
  assign clk_n_tracker = osc_clk_n > vth;
  
  wire change_observed;
  
  // Observer for the detector, when the analog clock is used in passive mode
  // This will monitor the analog clock(s) and send a secondary "sampling_do" signal (change_observed) when a change is seen
  // in the frequency of the signal
  osc_clk_observer #(.observer_en(passive), .diff_sel(diff_sel)) observer (.osc_clk(osc_clk), .osc_clk_p(osc_clk_p), 
    .osc_clk_n(osc_clk_n), .change_observed(change_observed));
  
  initial begin
	  sampling_done = 0;
  end

  always @(posedge sampling_do or posedge change_observed) begin
	  sampling_done = 0;
	  duration_counter = 0;
    sample_counter_p = 0;
    sample_counter_n = 0;
    clk_p_hi_time = -1.0; // also used for single-ended clock
    clk_p_lo_time = -1.0; // also used for single-ended clock
    clk_n_hi_time = -1.0;
    clk_n_lo_time = -1.0;    
    tsamp_p_ns = tsamp_nom_ns;
    tsamp_n_ns = tsamp_nom_ns;
    period_p_r = 0;
    period_n_r = 0;
    start_clk_period_calc = 0;
    start_clk_ampl_bias_calc = 0;
	  #(delay_int); // Measurement delay in ns
	  // init measurement
    if(diff_sel == 0) begin
	    Vclk_p = osc_clk;
    end
    else begin
	    Vclk_p = osc_clk_p;
	    Vclk_n = osc_clk_n;
    end
	  min_amp_p = Vclk_p;
	  max_amp_p = Vclk_p;
	  min_amp_n = Vclk_n;
	  max_amp_n = Vclk_n;
    
    start_clk_period_calc = 1;
    start_clk_ampl_bias_calc = 1;      
    
    fork
      begin : wait_for_duration_counter
        @(posedge duration_complete);
        disable timeout_thread;
      end
      begin : timeout_thread
        #(timeout_ns);
        disable wait_for_duration_counter;
        disable clk_period_calc;
        disable samp_clk_p_thread;
        disable samp_clk_n_thread;
      end
    join
    if(!passive)
      `uvm_ms_info("FREQ_UPDATE_DETECTED",$sformatf("The osc_clk generated by bridge is detected with freq=%e Hz period=%e ns", freq, period),UVM_MEDIUM)
    sampling_done <= 1;
  end

  always @(posedge start_clk_period_calc) begin
    period_p_r = 0;
    period_n_r = 0;
    while(duration_counter < duration_int) begin : clk_period_calc
      if(diff_sel == 0) begin //Single-ended clock
        @(posedge(clk_p_tracker));
        clk_p_hi_start = $realtime; //Start this positive half-cycle's calculation
        if(clk_p_lo_start > -1.0) //If there was a previous negedge sample (will not be if this was the first posedge)
          clk_p_lo_time = $realtime - clk_p_lo_start;
        
        //Calculate clk period on posedge of osc_clk
        if(sample_counter_p == 1)
          period_p_r = clk_p_hi_time + clk_p_lo_time;
        else if(sample_counter_p > 1)
          period_p_r = ((sample_counter_p - 1)*period_p_r + (clk_p_hi_time + clk_p_lo_time))/sample_counter_p; 
          //Moving average period
        
        sample_counter_p = sample_counter_p + 1;
        
        @(negedge(clk_p_tracker));
        clk_p_lo_start = $realtime;  //Start this negative half-cycle's calculation        
        if(clk_p_hi_start > -1.0) //If there was a previous posedge sample (there will be)
          clk_p_hi_time = $realtime - clk_p_hi_start;
        
      end
      else begin  //Differential clock
        fork 
          begin : clk_p_calc
            @(posedge(clk_p_tracker));
            clk_p_hi_start = $realtime; //Start this positive half-cycle's calculation
            if(clk_p_lo_start > -1.0) //If there was a previous negedge sample (will not be if this was the first posedge)
              clk_p_lo_time = $realtime - clk_p_lo_start;
            
            //Calculate clk period on posedge of osc_clk_p
            if(sample_counter_p == 1)
              period_p_r = clk_p_hi_time + clk_p_lo_time;
            else if(sample_counter_p > 1)
              period_p_r = ((sample_counter_p - 1)*period_p_r + (clk_p_hi_time + clk_p_lo_time))/sample_counter_p; 
              //Moving average period
            
            sample_counter_p = sample_counter_p + 1;
            
            @(negedge(clk_p_tracker));
            clk_p_lo_start = $realtime;  //Start this negative half-cycle's calculation        
            if(clk_p_hi_start > -1.0) //If there was a previous posedge sample (there will be)
              clk_p_hi_time = $realtime - clk_p_hi_start;
          end
          begin : clk_n_calc
            @(posedge(clk_n_tracker));
            clk_n_hi_start = $realtime; //Start this positive half-cycle's calculation
            if(clk_n_lo_start > -1.0) //If there was a previous negedge sample (will not be if this was the first posedge)
              clk_n_lo_time = $realtime - clk_n_lo_start;
            
            //Calculate clk period on posedge of osc_clk_n
            if(sample_counter_n == 1)
              period_n_r = clk_n_hi_time + clk_n_lo_time;
            else if(sample_counter_n > 1)
              period_n_r = ((sample_counter_n - 1)*period_n_r + (clk_n_hi_time + clk_n_lo_time))/sample_counter_n; 
              //Moving average period
            
            sample_counter_n = sample_counter_n + 1;
            
            @(negedge(clk_n_tracker));
            clk_n_lo_start = $realtime;  //Start this negative half-cycle's calculation        
            if(clk_n_hi_start > -1.0) //If there was a previous posedge sample (there will be)
              clk_n_hi_time = $realtime - clk_n_hi_start;
          end
        join
      end
      duration_counter = duration_counter + 1; //Only period calculation task updates the duration counter
    end
  end

  //This block measures the amplitude and bias (DC offset) of the analog clk signal(s) that the detector sees.
  //This is done by sampling the voltage of the clock signal in the positive and negative half-cycles, waiting for
  //three consecutive samples within a certain voltage tolerance, and writing that value to the respective half-cycle's
  //amplitude variable. 
  //Sampling rate is initially set to the parameter tsamp_nom_ns, and then updated to (0.05*period_<p/n>_r) respectively
  //This will provide approximately 10 samples per half-cycle (20 samples per cycle).
  
  always @(posedge start_clk_ampl_bias_calc) begin
    tsamp_p_ns = tsamp_nom_ns;
    tsamp_n_ns = tsamp_nom_ns;
    if(diff_sel == 0) begin
	    Vclk_p = osc_clk;
	    Vclk_n = 0.0;
    end
    else begin
	    Vclk_p = osc_clk_p;
	    Vclk_n = osc_clk_n;
    end
	  min_amp_p = Vclk_p;
	  max_amp_p = Vclk_p;
	  min_amp_n = Vclk_n;
	  max_amp_n = Vclk_n;
	  samp_clk_p = 0;
	  samp_clk_n = 0;
    fork
      begin : samp_clk_p_thread
        while (duration_counter < duration_int) begin
          if(period_p_r > 0) tsamp_p_ns = 0.05 * period_p_r; //20 samples per osc_clk(_p) cycle
          samp_clk_p = 0;
          #tsamp_p_ns;
          samp_clk_p = 1;
          #tsamp_p_ns;
        end        
      end
      
      begin : samp_clk_n_thread
        if(diff_sel == 1) begin 
          while (duration_counter < duration_int) begin
            if(period_n_r > 0) tsamp_n_ns = 0.05 * period_n_r; //20 samples per osc_clk(_p) cycle
            samp_clk_n = 0;
            #tsamp_n_ns;
            samp_clk_n = 1;
            #tsamp_n_ns;
          end
        end
      end
    join
  end
  
  always @(samp_clk_p) begin
    if(diff_sel == 0) begin //Single-ended clock signal
      if(osc_clk > max_amp_p) max_amp_p = osc_clk;
      if(osc_clk < min_amp_p) min_amp_p = osc_clk;
    end
    else begin  //Differential clock signal
      if(osc_clk_p > max_amp_p) max_amp_p = osc_clk_p;
      if(osc_clk_p < min_amp_p) min_amp_p = osc_clk_p;
    end      
  end
  
  always @(samp_clk_n) begin
    if(osc_clk_n > max_amp_n) max_amp_n = osc_clk_n;
    if(osc_clk_n < min_amp_n) min_amp_n = osc_clk_n;
  end
  
endmodule

// Analog clock observer module. Will send a pulse on the "change_observed" port if a change in signal
// frequency is observed (beyond a tolerance) on the given clock signal.

module osc_clk_observer import cds_rnm_pkg::*; (
  input wreal4state osc_clk,
  input wreal4state osc_clk_p, 
  input wreal4state osc_clk_n,
  output bit change_observed
  );

  // UVM for message reporting
  import uvm_pkg::*;
//  `include "uvm_macros.svh"
  `include "uvm_ms.vdmsh"

  parameter bit observer_en = 0;      //Observer enabled. 0 -> change_observed = 0, 1 -> change_observed will 
                                      //pulse on clock frequency change
  parameter bit diff_sel = 0;         //Differential clock selection. 0 = single-ended clock, 1 = diff. clock
  parameter real freq_tol = 1.0e6;    //Frequency change tolerance in Hz
  
  parameter real peak_tol = 1.0e-3;
  
  real observed_freq, prev_freq;
  
  // measured properties
  real min_a, max_a;
  real bias;
  real ampl;
  real ampl_r;
  
  // temporaries
  real pos_x_time; // positive derivative zero crossing
  real pos_x_time_last;
  real period;
  
  assign ampl = ampl_r; 
  assign bias = (max_a + min_a) / 2;
  assign period = abs(pos_x_time - pos_x_time_last);
  
  // To observe freq change:
  // 1. measure max, min -> get the bias point -> get value of period -> measure freq
  // 2. compare freq with freq_prev
  
  bit change_observed_int;
  always@(posedge(abs(observed_freq - prev_freq) > freq_tol)) begin
  	if(observed_freq == 0) prev_freq = 0;
		change_observed_int = 1;
		#1ps;
		change_observed_int = 0;
  end

  assign change_observed = observer_en ? change_observed_int : 1'b0;
  integer count;
  initial count = 0;
  real last_osc_clk;
  bit timeout;
  bit passFirst;
  
  // internal value for osc_clk or osc_clk_p or osc_clk_n
  real osc_clk_int;
  assign osc_clk_int = (diff_sel == 0) ? osc_clk: osc_clk_p;
  
  always begin
		INVALID_OSC_CLK_ASSERT: assert((osc_clk_int != `wrealZState)||(osc_clk_int != `wrealXState))
    else `uvm_ms_warning("INVALID_OSC_CLK", $sformatf("osc_clk or osc_clk_p = %b", osc_clk_int))

    if (osc_clk_int > max_a) begin
			max_a = osc_clk_int;
		end
		if (osc_clk_int < min_a) begin
			min_a = osc_clk_int;
		end
		
		// check if the input amplitude change and update the max and min accordingly
		// if at the peak or bottom but not equal to either max or min, then change both max and min to this value
		if(osc_clk_int == last_osc_clk) begin
			// when the bias changed, max_a and min_a need to be updated
			if (((abs(osc_clk_int - max_a) > peak_tol) && (abs(osc_clk_int - min_a) > peak_tol))) begin
				if(count >3) begin
					max_a = osc_clk_int;
					min_a = osc_clk_int;
					count = 0;
				end
				
			end
			// when the freq drops to zero
			else begin
				//count = count + 1;
				// For freq = 5e8 Hz (minimum freq with transaction constraint), half of the period is 1ns
        // 100fs*10000 samples= 1ns => we sample the osc_clk 10000 times, which is half of a clock cycle (1ns).
				if(count > 4500) begin // Timeout case: when the clock signal stays the same for 25000 samples, in case of the frequency doubler cycles is 2ns
					observed_freq = 0;
					count = 0;
          timeout = (!passFirst) ? 0 : 1;
          end
			end
			count = count + 1;
		end
		else count = 0;

		// // get the time of the positive crossing at bias 
    // similar triangle
    if ((last_osc_clk <= bias) && (osc_clk_int > bias)) begin
      passFirst = 1;
			pos_x_time_last = pos_x_time;
			pos_x_time = $realtime - (((osc_clk_int - bias) *(1ps)) / (osc_clk_int + abs(last_osc_clk)));
			prev_freq = observed_freq;
			observed_freq = (period == 0 ? 0 : 1e9/period);
      INSUFFICIENT_SAMPLES_ASSERT: assert(!timeout) 
      else `uvm_ms_warning("INSUFFICIENT_SAMPLES", "The clock observer should wait for longer to determine a zero frequency. May need to increase the sampling duration (>4500).")
      timeout = 0;
		end
		last_osc_clk = osc_clk_int;
		ampl_r = (max_a - min_a);
		#1ps;
  end
  
endmodule

//Floating-point absolute function. This is needed because SV does not have a pre-defined floating point absolute
//function.
function real abs(input real A); 
  abs = (A<0)? -A:A; 
endfunction


