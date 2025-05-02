// Monitor of registers UVC

class registers_monitor extends uvm_monitor;
  registers_packet pkt;
  
  uvm_analysis_port#(registers_packet) item_collected_port;
  uvm_analysis_port#(registers_packet) item_ms_collected_port;
  
  // Config property for coverage enable lab10
  cover_e coverage_control = COV_ENABLE;
  
  virtual interface registers_if reg_vif; 
   
   // counter of collected packets
	int num_pkt_col;
	
  // component macro
  `uvm_component_utils_begin(registers_monitor)
  	`uvm_field_int(num_pkt_col, UVM_ALL_ON)
    `uvm_field_enum(cover_e, coverage_control, UVM_ALL_ON)
  `uvm_component_utils_end
  
  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
    item_ms_collected_port = new("item_ms_collected_port", this);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

	function void connect_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual registers_if)::get(this, get_full_name(), "reg_vif", reg_vif))
			`uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reg_vif"})
	endfunction: connect_phase

  // UVM run_phase()
  task run_phase(uvm_phase phase);
    collect_and_monitor();
      
  endtask : run_phase

	task collect_and_monitor();
		`uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
		@(posedge(reg_vif.sig_en));//Avoiding time=0 packet collection
		forever begin 
	    // Create collected packet instance
	    pkt = registers_packet::type_id::create("pkt", this);
			// trigger transaction at start of packet
	    void'(begin_tr(pkt, "Monitor_registers_Packet"));
			reg_vif.collect_packet(pkt.addr, pkt.wdata, pkt.wen, pkt.ren);
	    
	    item_collected_port.write(pkt);
	    
	    end_tr(pkt);// End transaction recording

	    num_pkt_col++;
    end
	endtask : collect_and_monitor

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: registers Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase

endclass : registers_monitor
