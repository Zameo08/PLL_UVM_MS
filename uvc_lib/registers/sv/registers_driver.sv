// Driver of registers UVC

class registers_driver extends uvm_driver #(registers_packet);
	// Declare this property to count packets sent
  int num_sent;
  virtual interface registers_if reg_vif; 
  
	// component macro
  `uvm_component_utils_begin(registers_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
  `uvm_component_utils_end
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual registers_if)::get(this,"","reg_vif", reg_vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reg_vif"})
  endfunction: connect_phase

// UVM run_phase
  task run_phase(uvm_phase phase);
    reset_signals();
    get_and_drive();
  endtask : run_phase
  
  // Resets registers to 0
  task reset_signals();
    bit [7:0] i;
    `uvm_info(get_type_name(),$sformatf("Resetting register signals"),UVM_MEDIUM)    
    for(i = 8'd0; i < 8'd3; i++) begin
      fork
        reg_vif.send_to_dut(i, 8'b0, 1, 0);
        begin
      		reg_vif.sig_en = 1;
      		#(1ps) reg_vif.sig_en = 0; //negedge -> send_to_dut task will drive reg bus
      		#(1ps) reg_vif.sig_en = 1; //posedge -> register DUT will be consuming driver output
        end
      	#(199.999ns);
    	join
  	end
  endtask
  
  // Gets packets from the sequencer and passes them to the driver. 
  task get_and_drive();
    forever begin
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);

      // packet driving and transaction recording
      void'(begin_tr(req, "Driver_registers_Packet"));
      fork
      	begin
	      	reg_vif.send_to_dut(req.addr, req.wdata, 1, 0); // Set wren to 1 and ren to 0
	      end
      	begin
      		reg_vif.sig_en = 1;
      		#(1ps) reg_vif.sig_en = 0; //negedge -> send_to_dut task will drive reg bus
      		#(1ps) reg_vif.sig_en = 1; //posedge -> register DUT will be consuming driver output
      	end
      	#(199.999ns);
    	join
        
      // End transaction recording
      end_tr(req);
      num_sent++;
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end  
  endtask : get_and_drive
	
	 // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: registers driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase
	
endclass: registers_driver
