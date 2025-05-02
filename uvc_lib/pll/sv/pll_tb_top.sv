`timescale 1ns/1fs
module pll_tb_top;
  import uvm_pkg::*;
  import pll_pkg::*;
  `include "uvm_macros.svh"

  logic clk, rst_n;
  wire fref, fout;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  pll_if pll_if_inst ();

  pll pll_inst (
    .fref(fref),
    .fout(fout)
  );

  pll_bridge bridge_inst (
    .fref(fref),
    .fout(fout)
  );

  initial begin
    uvm_config_db #(virtual pll_if)::set(null, "*", "vif", pll_if_inst);
    uvm_config_db #(pll_bridge_proxy)::set(null, "*", "bridge_proxy", bridge_inst.__uvm_ms_proxy);
    run_test("pll_test");
  end
endmodule