class pll_sequencer extends uvm_sequencer #(pll_transaction);
  `uvm_component_utils(pll_sequencer)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass: pll_sequencer