interface osc_if ();

  timeunit 1ns;
  timeprecision 1fs;

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh" 

  logic sig_en;
  
  // signals driven from driver to interface (packet)
  logic clk = 1'bz;
  int freq;
    
  // DUT signals
  wire osc_clk = clk;	// Single-ended clock
  wire osc_clk_p, osc_clk_n; // Differential clock
  
  // Control flags
  bit has_checks = 1;
  bit has_coverage = 1;

  event new_drv_values;

  event drvstart;
    
  task send_to_dut(input int freq_seq);
    // Drive the DUT with packet
  `uvm_info("OSC_IF", "sending packet to DUT", UVM_HIGH)
    @(negedge sig_en);
    freq = freq_seq;
    ->drvstart;
  endtask : send_to_dut
    
endinterface : osc_if
