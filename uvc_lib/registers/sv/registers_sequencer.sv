// Sequencer in registers UVC

class registers_sequencer extends uvm_sequencer #(registers_packet);
	`uvm_component_utils(registers_sequencer)
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
	endfunction
	
endclass: registers_sequencer
