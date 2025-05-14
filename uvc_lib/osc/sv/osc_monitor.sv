//------------------------------------------------------------------------------
//
// CLASS: osc_monitor
//
//------------------------------------------------------------------------------
class osc_monitor extends uvm_monitor;

  // Virtual Interface for monitoring DUT signals
  virtual interface osc_if vif;

  // Count transaction collected
  int num_col_in, num_col_out;
  
  // decide which signal to monitor in differential outputs
   bit diff_sel;
  
  // measure the output frequency (both clk_out_p and clk_out_n)
  real tupd_outp = 0;
  real tupd_outn = 0;
  event between_two_negedge_outp;
  
  real last_freq_out_p;
  real last_freq_out_n;
  
  real temp_period_p;
  real temp_period_n;
  
  int being_stable_checker;
  
  logic stable_comfirm_checker;
  
  // freq_generator monitor variables
  int last_freq;
  real period;
  real tupd;
  real freq_tol = 10e6; // unit: Hz

  // //measurement flags (configurable by test case)
  // bit measure_freq = 1;
  // bit measure_lock_time = 0;
  // bit measure_jitter = 0;
  // bit measure_phase_error = 0;

  
  osc_transaction osc_clk_transaction, osc_clk_p_transaction;
   
  // This TLM port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(osc_transaction) item_collected_port;
 
  // Provide UVM automation and utility methods
  `uvm_component_utils_begin(osc_monitor)
    `uvm_field_int(num_col_in, UVM_ALL_ON)
    `uvm_field_int(num_col_out, UVM_ALL_ON)
    `uvm_field_int(diff_sel, UVM_ALL_ON)
    // `uvm_field_int(measure_freq, UVM_ALL_ON)
    // `uvm_field_int(measure_lock_time, UVM_ALL_ON)
    // `uvm_field_int(measure_jitter, UVM_ALL_ON)
    // `uvm_field_int(measure_phase_error, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Create the covergroup only if coverage is enabled
    item_collected_port = new("item_collected_port", this);
  endfunction : new
  
  function real abs(input real A); 
      abs = (A<0)? -A:A; 
  endfunction
      
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get measure configuration from config_db
    // uvm_config_db#(bit)::get(this,"", "measure_freq", measure_freq);
    // uvm_config_db#(bit)::get(this,"", "measure_lock_time", measure_lock_time);
    // uvm_config_db#(bit)::get(this,"", "measure_jitter", measure_jitter);
    // uvm_config_db#(bit)::get(this,"", "measure_phase_error", measure_phase_error);
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual osc_if)::get(this, get_full_name(), "vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
    if (!uvm_config_int::get(this,"","diff_sel", diff_sel))
      `uvm_error("NOCONFIG",{"value must be set for: ",get_full_name(),".diff_sel"})
    else  `uvm_info("CONFIG_CORRECT",{"Value of ",get_full_name(), $sformatf(".diff_sel = %d",diff_sel)}, UVM_LOW)
  endfunction: connect_phase
  
  // UVM run() phase
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    collect_DUT_output();
  endtask : run_phase

  virtual task collect_DUT_output();
    if(diff_sel == 1) begin
      osc_clk_p_transaction = osc_transaction::type_id::create("osc_clk_p_transaction", this);
      being_stable_checker = 0;
      stable_comfirm_checker = 0;
      forever begin
        void'(this.begin_tr(osc_clk_p_transaction, "OSC_Monitor_diff"));
        // Measure osc_clk_p
        @(posedge vif.osc_clk_p);  
        //#1fs;
        last_freq_out_p = osc_clk_p_transaction.freq;
        temp_period_p = $realtime-tupd_outp;
        if (tupd_outp>0) begin
          osc_clk_p_transaction.freq=(1s/(temp_period_p));  //  compute Freq=1/period (Hz)
          osc_clk_p_transaction.diff_sel = diff_sel;
        end
        tupd_outp = $realtime;                     //   and save edge time
        // if the freq repeated for 8 times and within the tolerance range (stable enough), then write into scoreboard
        // The duplicate check is set to 8 here in order to cover the freq doubler case since the duplicate checker in freq_generator_monitor is 4 (8 = 4*2)
        if((abs(last_freq_out_p - osc_clk_p_transaction.freq) < freq_tol)&&(being_stable_checker == 8))begin
          item_collected_port.write(osc_clk_p_transaction);
          being_stable_checker ++;
          stable_comfirm_checker = 1;
        end
        else if((abs(last_freq_out_p - osc_clk_p_transaction.freq) < freq_tol)&&(being_stable_checker != 8))begin
          being_stable_checker ++;
          stable_comfirm_checker = 0;
        end
        else if(abs(last_freq_out_p - osc_clk_p_transaction.freq) >= freq_tol) begin
          being_stable_checker = 0;
          if(stable_comfirm_checker) begin
            osc_transaction temp_transaction;
            temp_transaction = osc_transaction::type_id::create("temp_transaction", this);
            temp_transaction.freq = -1; // write -1 as the output frequency to scoreboard if the output becomes unstable
            item_collected_port.write(temp_transaction);
            stable_comfirm_checker = 0;
          end
        end
        this.end_tr(osc_clk_p_transaction);
        num_col_out++;
        `uvm_info(get_type_name(), $sformatf("Report: Monitor Collected differential output %d time(s).", num_col_out), UVM_FULL)
      end
    end
    // Meausre osc_clk
    else if(diff_sel == 0) begin
      forever begin
        fork
          begin: meas_osc_clk_freq
            @(posedge vif.sig_en);
            osc_clk_transaction = osc_transaction::type_id::create("osc_clk_transaction", this);
            void'(begin_tr(osc_clk_transaction, "OSC_Monitor_sing_ended"));
            forever begin
              @(posedge vif.osc_clk);
              last_freq = osc_clk_transaction.freq;
              period = $realtime-tupd;
              osc_clk_transaction.freq=(1s/(period));  //  compute Freq=1/period (Hz)
              tupd = $realtime;                     //   and save edge time
              
              // if the freq repeated for 4 times and within the tolerance range (stable enough), then write into scoreboard
              if((abs(last_freq - osc_clk_transaction.freq) < freq_tol)&&(being_stable_checker == 4))begin
                osc_clk_transaction.diff_sel = diff_sel;
                item_collected_port.write(osc_clk_transaction);
                being_stable_checker ++;
              end
              else if((abs(last_freq - osc_clk_transaction.freq) < freq_tol)&&(being_stable_checker != 4))begin
                being_stable_checker ++;
              end
              else if(abs(last_freq - osc_clk_transaction.freq) >= freq_tol) begin
                being_stable_checker = 0;
              end
              end_tr(osc_clk_transaction);
            end
          end
          
          begin
            @(negedge vif.sig_en)
            disable meas_osc_clk_freq; // stop measuring when the testcase switches
            num_col_in++;
            `uvm_info(get_type_name(), $sformatf("Report: Monitor Collected %0d osc_clk_transactions", num_col_in), UVM_FULL)
            last_freq = 0;
          end
          
        join 
      end
    end

  endtask : collect_DUT_output
  

  // UVM report() phase
  function void report_phase(uvm_phase phase);
    if(diff_sel == 1)
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: osc_monitor collected frequency %0d times in total.", num_col_in),
      UVM_LOW)
    else if(diff_sel == 0)
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: osc_monitor collected frequency %0d times in total.", num_col_out),
      UVM_LOW)
  endfunction 
  
  
endclass : osc_monitor



/*-----------------------------------------------------------------
File name     : osc_ms_source_monitor.sv
Description   : This file implements the source monitor.
              : The source monitor monitors the activity of
              : its interface bus.
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: osc_ms_source_monitor
//
//------------------------------------------------------------------------------

// File: osc_ms_source_monitor.sv
class osc_ms_source_monitor extends osc_monitor;

  // Virtual Interface for monitoring DUT signals
  protected osc_bridge_proxy bridge_proxy;
  // Count transactions collected
  int num_col;

  // Measurement flags (configurable by test case)
  bit measure_freq = 1;
  bit measure_lock_time = 0;
  bit measure_jitter = 0;
  bit measure_phase_error = 0;

  // Control for checks and coverage
  bit checks_enable = 1;
  bit coverage_enable = 1;
  bit use_vector_coverage = 0;
  bit use_real_coverage = 1;

  // Current monitored transaction
  protected osc_ms_transaction transaction;

  bit [63:0] phase_vec;
  bit [63:0] ampl_vec;
  bit [63:0] bias_vec;
  bit [63:0] freq_vec;

  real phase_r;
  real ampl_r;
  real bias_r;
  real freq_r;

  // Covergroup for transaction
  covergroup vector_bin_cg;
    option.per_instance = 1;
    data_type : coverpoint transaction.data_type;
    amplitude : coverpoint ampl_vec {
      bins MilliVolts        = {[0:64'h3F50624DD2F1A9FC]};
      bins TenMilliVolts     = {[64'h3F50624DD2F1A9FC:64'h3FB999999999999A]};
      bins HundredMilliVolts = {[64'h3FB999999999999A:64'h3FECCCCCCCCCCCCD]};
      bins OneVolt           = {[64'h3FECCCCCCCCCCCCD:64'h3FF6666666666666]};
      bins TwoVolts          = {[64'h3FF6666666666666:64'h3FFE666666666666]};
      bins UnderFiveVolts    = {[64'h3FFE666666666666:64'h4014000000000000]};
      bins TenVolts          = {[64'h4014000000000000:64'h4024000000000000]};
      bins TenPlusVolts      = {[64'h4024000000000000:64'h412E848000000000]};
      bins Max               = {[64'h412E848000000000:$]};
    }
    frequency : coverpoint freq_vec {
      bins DC         = {[0:64'h3FECCCCCCCCCCCCD]};
      bins Hz         = {[64'h3FECCCCCCCCCCCCD:64'h40C3880000000000]};
      bins KHz        = {[64'h40C3880000000000:64'h416312D000000000]};
      bins MHz        = {[64'h416312D000000000:64'h4197D78400000000]};
      bins TenMhz     = {[64'h4197D78400000000:64'h41CDCD6500000000]};
      bins HundredMhz = {[64'h41CDCD6500000000:64'h4202A05F20000000]};
      bins GHz        = {[64'h4202A05F20000000:64'h42374876E8000000]};
      bins Max        = {[64'h42374876E8000000:$]};
    }
  endgroup : vector_bin_cg

  // Provide UVM automation and utility methods
  `uvm_component_utils_begin(osc_ms_source_monitor)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_field_int(measure_freq, UVM_ALL_ON)
    `uvm_field_int(measure_lock_time, UVM_ALL_ON)
    `uvm_field_int(measure_jitter, UVM_ALL_ON)
    `uvm_field_int(measure_phase_error, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    void'(get_config_int("coverage_enable", coverage_enable));
    if (coverage_enable) begin
      vector_bin_cg = new();
      vector_bin_cg.set_inst_name("vector_bin_cg");
    end
  endfunction : new

  // Additional class methods
  extern virtual task run();
  extern virtual protected task collect_transaction();
  extern virtual protected function void perform_checks();
  extern virtual protected function void perform_coverage();
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual protected function void perform_measurements();
  extern virtual protected task meas_lock_time(output real lock_time);
  extern virtual protected task meas_jitter(output real jitter_rms);
  extern virtual protected task meas_phase_error(output real phase_error);
  extern virtual protected task meas_frequency(output real out_freq);
  extern virtual protected function void log_measure();

  // transaction.lock_time = meas_lock_time();
  // transaction.jitter_rms = meas_jitter();
  // transaction.measured_freq = meas_frequency();
  // transaction.phase_error = meas_phase_error();
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(osc_bridge_proxy)::get(this, "", "bridge_proxy", bridge_proxy))
      `uvm_error(get_type_name(), "bridge proxy not configured");
    void'(uvm_config_db#(bit)::get(this, "", "measure_freq", measure_freq));
    void'(uvm_config_db#(bit)::get(this, "", "measure_lock_time", measure_lock_time));
    void'(uvm_config_db#(bit)::get(this, "", "measure_jitter", measure_jitter));
    void'(uvm_config_db#(bit)::get(this, "", "measure_phase_error", measure_phase_error));
  endfunction

  // UVM run() phase
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    run();
  endtask : run_phase

endclass : osc_ms_source_monitor

  task osc_ms_source_monitor::run();
    fork
      collect_transaction();
    join_none
  endtask : run

  task osc_ms_source_monitor::collect_transaction();
    transaction = osc_ms_transaction::type_id::create("transaction", this);
    forever begin
      @(posedge bridge_proxy.sampling_done);
      void'(begin_tr(transaction, "analog_clock source Monitor"));
      transaction.data_type = OSC_MS_SAMPLE;
      transaction.ampl = bridge_proxy.ampl_out;
      transaction.bias = bridge_proxy.bias_out;
      transaction.freq = bridge_proxy.freq_out;
      `uvm_info(get_type_name(), 
        $psprintf("source transaction collected :\n%s", transaction.sprint()), UVM_LOW);
      if (checks_enable)
        perform_checks();
      if (coverage_enable)
        perform_coverage();
      perform_measurements();
      item_collected_port.write(transaction);
      num_col++;
      fork
        begin : wait_for_sampling_done
          @(negedge bridge_proxy.sampling_done);
          disable wait_for_timeout;
        end
        begin : wait_for_timeout
          #150ns;
          disable wait_for_sampling_done;
        end
      join
      end_tr(transaction);
    end
  endtask : collect_transaction

  function void osc_ms_source_monitor::perform_checks();
    // Add protocol checks here
  endfunction : perform_checks

  function void osc_ms_source_monitor::perform_coverage();
    ampl_vec = $realtobits(transaction.ampl);
    bias_vec = $realtobits(transaction.bias);
    freq_vec = $realtobits(transaction.freq);
    `uvm_info(get_type_name(), "Gathering analog coverage via bit vectors", UVM_MEDIUM);
    vector_bin_cg.sample();
  endfunction : perform_coverage

  function void osc_ms_source_monitor::report_phase(uvm_phase phase);
    log_measure();
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: ANALOG_CLOCK source monitor collected %0d transactions", num_col),
      UVM_LOW);
  endfunction

  function void osc_ms_source_monitor::perform_measurements();
  // `uvm_info(get_type_name(), 
  //   $sformatf("\nReport: ANALOG_CLOCK source monitor collected %0d transactions", num_col),
  //   UVM_LOW);
endfunction
  // task osc_ms_source_monitor::perform_measurements(output real lock_time, jitter_rms, phase_error, freq);
    
  //   if (measure_lock_time) begin
  //     meas_lock_time(lock_time);
  //     transaction.lock_time = lock_time;
  //   end
  //   if (measure_jitter) begin
  //     meas_jitter(jitter_rms);
  //     transaction.jitter_rms = jitter_rms;
  //   end
  //   if (measure_phase_error) begin
  //     meas_phase_error(phase_error);
  //     transaction.phase_error = phase_error;
  //   end
  //   if (measure_freq) begin
  //     meas_frequency(freq);
  //     transaction.measured_freq = freq;
  //   end
  //   log_measure();
  // endtask

  task osc_ms_source_monitor::meas_lock_time(output real lock_time);
    real start_time;
    bit locked = 0;
    real current_freq;
    start_time = $realtime;
    while (!locked && ($realtime - start_time < 1e6)) begin
      @(posedge vif.osc_clk);
      meas_frequency(current_freq);
      if (abs(current_freq - transaction.freq) < 0.01 * transaction.freq) begin
        locked = 1;
      end
    end
    lock_time = ($realtime - start_time) * 1e-9; // Convert to seconds
  endtask

  task osc_ms_source_monitor::meas_jitter(output real jitter_rms);
    real periods[$];
    real avg_period, sum_sq_diff;
    real sum_periods = 0.0;
    int num_samples = 100;
    for (int i = 0; i < num_samples; i++) begin
      real start_time = $realtime;
      @(posedge vif.osc_clk);
      periods.push_back(($realtime - start_time) * 1e-9);
    end
    
    foreach (periods[i]) begin
      sum_periods += periods[i];
    end
    avg_period = sum_periods / num_samples;
    sum_sq_diff = 0;
    foreach (periods[i]) begin
      sum_sq_diff += (periods[i] - avg_period) ** 2;
    end
    jitter_rms = $sqrt(sum_sq_diff / num_samples) * 1e12; // Jitter RMS (ps)
  endtask

  task osc_ms_source_monitor::meas_phase_error(output real phase_error);
    real ref_time, pll_time;
    @(posedge vif.osc_clk);
    ref_time = $realtime;
    @(posedge vif.osc_clk);
    pll_time = $realtime;
    phase_error = ((pll_time - ref_time) * 360.0 / (1e9 / transaction.measured_freq)); // Degrees
  endtask

  task osc_ms_source_monitor::meas_frequency(output real out_freq);
    real start_time, end_time;
    int cycle_count = 10;
    @(posedge vif.osc_clk);
    start_time = $realtime;
    repeat(cycle_count) @(posedge vif.osc_clk);
    end_time = $realtime;
    out_freq = (cycle_count / ((end_time - start_time) * 1e-9)); // Hz
  endtask

  function void osc_ms_source_monitor::log_measure();
    string log_msg = "";
    if (measure_freq)
      log_msg = $sformatf("%s [REPORT_MONITOR]_Freq=%0f Hz", log_msg, transaction.measured_freq);
    if (measure_lock_time)
      log_msg = $sformatf("%s [REPORT_MONITOR]_Lock_time=%0f ns", log_msg, transaction.lock_time);
    if (measure_jitter)
      log_msg = $sformatf("%s [REPORT_MONITOR]_Jitter_rms=%0f ps", log_msg, transaction.jitter_rms);
    if (measure_phase_error)
      log_msg = $sformatf("%s [REPORT_MONITOR]_Phase_error=%0f deg", log_msg, transaction.phase_error);
    `uvm_info("MONITOR", $sformatf("[REPORT_MONITOR]_Measurement: %s", log_msg), UVM_MEDIUM);
  endfunction
