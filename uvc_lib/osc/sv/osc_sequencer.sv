
class osc_sequencer extends uvm_sequencer #(osc_transaction);
	`uvm_component_utils(osc_sequencer)
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass: osc_sequencer
