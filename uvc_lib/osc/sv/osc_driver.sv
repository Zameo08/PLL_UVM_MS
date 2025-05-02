//------------------------------------------------------------------------------
//
// CLASS: freq_adpt_in_adpt_driver
//
//------------------------------------------------------------------------------

class osc_driver extends uvm_driver #(osc_transaction);

  // The virtual interface used to drive and view HDL signals.
  virtual interface osc_if vif;
 
  // Count transactions sent
  int num_sent;
  
  // period of the generated clock
  real period;

	// component macro
  `uvm_component_utils_begin(osc_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
    `uvm_field_real(period, UVM_ALL_ON)
  `uvm_component_utils_end
  
  int test_config;

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
  endfunction
  
	function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual osc_if)::get(this,"","vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: connect_phase
  
  // UVM run() phase
  task run_phase(uvm_phase phase);
    	get_and_drive();
  endtask : run_phase

  // Gets packets from the sequencer and passes them to the driver. 
  virtual task get_and_drive();
    forever begin			
			seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
      // packet driving and transaction recording
      void'(begin_tr(req, "FREQ_GENERATOR Driver"));
			fork
				vif.send_to_dut(req.freq); // ignore dutycycle by changing it to zero
				begin
      		vif.sig_en = 1;
      		#(1ps) vif.sig_en = 0; //negedge -> send_to_dut task will drive reg bus
      		#(1ps) vif.sig_en = 1; //posedge -> register DUT will be consuming driver output
      	end
				begin: clk_gen
					@(posedge vif.sig_en)
					// period of generated input clock
					period = 1/(req.freq); // unit of freq: Hz
					clock_in_gen(period); 
				end
				begin
					@(posedge vif.sig_en);
					//Time for transaction
					#(200*1ns) disable clk_gen; // stop the clk_gen when a test case ends
					vif.clk = 0;
				end
			join
				
			// End transaction recording
			end_tr(req);
			// Communicate item done to the sequencer
			seq_item_port.item_done();
			num_sent ++;
			//`uvm_info(get_type_name(), $sformatf("freq_generator packet sent :\n%s", req.sprint()), UVM_LOW)

    end
  endtask : get_and_drive
	// clock generator for the DUT input
	task clock_in_gen(input real period);
		vif.clk = 0; // keep clock of every test case starts from zero
		forever begin
			#(period *50 *0.01 *1s)
			vif.clk = !vif.clk;
		end
		
	endtask

  // UVM report() phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: OSC driver sent %0d packets in total.",
      num_sent), UVM_LOW)
  endfunction 
  
endclass : osc_driver


//------------------------------------------------------------------------------
//
// CLASS: osc_ms_source_driver
//
//------------------------------------------------------------------------------
class osc_ms_source_driver extends osc_driver;

  protected osc_bridge_proxy bridge_proxy;
  
  osc_ms_transaction ms_req;
  
  // Count transactions sent
  int num_sent;
  // Get value to drive onto diff_sel
  bit diff_sel;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(osc_ms_source_driver)
    `uvm_field_int(diff_sel, UVM_ALL_ON)
  `uvm_component_utils_end
  
  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task get_and_drive();
  extern virtual task reset_signals();
  extern virtual task drive_transaction(osc_ms_transaction transaction);
  extern virtual function void report_phase(uvm_phase phase);

  virtual function void build_phase(uvm_phase phase);
  	super.build_phase(phase);

    if(!uvm_config_db#(osc_bridge_proxy)::get(this,"","bridge_proxy",bridge_proxy))
      `uvm_error(get_type_name(),"bridge proxy not configured");
  endfunction
  
endclass : osc_ms_source_driver

// UVM run() phase
task osc_ms_source_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
    get_and_drive();
    //reset_signals();
  join
endtask

// Gets transactions from the sequencer and passes them to the driver. 
task osc_ms_source_driver::get_and_drive();
  forever begin
    // Get new item from the sequencer
    seq_item_port.get_next_item(req);
    $cast(ms_req,req);
    // Drive the item
    drive_transaction(ms_req);
    fork
      #(200*1ns); //Time for transaction
      begin : sample_thread
        #(1ns) bridge_proxy.sampling_do = 1;
        #(1ns) bridge_proxy.sampling_do = 0;
      end
    join
    // Communicate item done to the sequencer
    seq_item_port.item_done();
  end
endtask : get_and_drive

// Reset all master signals
task osc_ms_source_driver::reset_signals();
  forever begin
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
    // Add signal that should be reset here
  end
endtask : reset_signals

// Gets a transaction and drive it into the DUT
task osc_ms_source_driver::drive_transaction(osc_ms_transaction transaction);
  `uvm_info(get_type_name(), $psprintf("Item %0d To Send ... :\n%s", num_sent, transaction.sprint()), UVM_HIGH)
  if (transaction.data_type == OSC_MS_DRIVE) begin
    bridge_proxy.config_wave(.ampl(transaction.ampl),.bias(transaction.bias),.freq(transaction.freq),
      .enable(transaction.enable));
    bridge_proxy.delay_in = transaction.delay;
    bridge_proxy.duration_in = transaction.duration;      
    num_sent++;
    `uvm_info(get_type_name(), $psprintf("Item %0d Sent ...", num_sent), UVM_MEDIUM)
  end
  else begin
    `uvm_info(get_type_name(), "Only Drive transaction are supported in the driver", UVM_LOW)
  end
  
endtask : drive_transaction

// UVM report() phase
function void osc_ms_source_driver::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), 
    $sformatf("\nReport: OSC_MS driver sent %0d transactions",
    num_sent), UVM_LOW)
endfunction 


