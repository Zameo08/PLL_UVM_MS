interface pll_if ();

  timeunit 1ns;
  timeprecision 1fs;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  logic sig_en;
  logic clk = 1'bz;
  real freq;

  wire fref = clk;  // Tín hiệu tham chiếu
  wire fout;        // Tín hiệu đầu ra

  bit has_checks = 1;
  bit has_coverage = 1;

  event new_drv_values;
  event drvstart;

  task send_to_dut(input real freq_seq);
    @(negedge sig_en);
    freq = freq_seq;
    ->drvstart;
  endtask : send_to_dut

endinterface : pll_if