`timescale 1ns/1ps
module top import cds_rnm_pkg::*;;
  
  //Import the UVM library
  import uvm_pkg::*;

  //Include the UVM macros
  `include "uvm_macros.svh"

  //Import the UVC packages
  import osc_pkg::*;
  import registers_pkg::*;
  

  //Include the test library file
  `include "pll_scoreboard.sv"
  `include "pll_tb.sv"
  `include "test_lib.sv"
  
  //Clock and reset signals
  wire clkout_p, clkout_n;
  wire clk_in;
  reg rst_n;
  bit reg_clk;
  bit [7:0] div_cfg;
  bit [3:0] vco_gain;
  bit [1:0] lpf_rp;
  bit [1:0] lpf_cp;
  bit [1:0] lpf_c2;
  bit       enable_pll;

  //Interfaces to the DUT
  osc_if generator_if (); 
  osc_if detector_if ();

  registers_if reg_if();
  
  registers regi(
    .rst_n(rst_n),
    .addr(reg_if.addr), 
    .wdata(reg_if.wdata), 
    .wen(reg_if.wen), 
    .ren(reg_if.ren), 
    .clk(reg_if.sig_en), 
    .rdata(reg_if.rdata), 
    .div_cfg(div_cfg),        //Pulse-width adjustment
    .vco_gain(vco_gain),        //Mux enable
    .lpf_rp(lpf_rp),      //Mux selection
    .lpf_cp(lpf_cp),    //Amplitude adjustment
    .lpf_c2(lpf_c2),
    .enable_pll(enable_pll)         //Slew-rate adjustment
  );
  wire freq_in;
  wire freq_out;
  //Mapping the register interface to the register instantiation
  assign reg_if.div_cfg = div_cfg;
  assign reg_if.vco_gain = vco_gain;
  assign reg_if.lpf_rp = lpf_rp;
  assign reg_if.lpf_cp = lpf_cp;
  assign reg_if.enable_pll = enable_pll;
  
  //For a pure digital DUT, we are mapping the inputs and outputs directly to the generator and detector
  //interface nets respectively
  //For a mixed-signal DUT (AMS/DMS), we are instantiating MS bridges for the generator and detector UVCs.
  //These will in-turn instantiate analog resources that will perform the generation and detection operations
  //for the UVCs.
  `ifdef UVM_AMS
  osc_bridge #(.diff_sel(0)) generator_bridge (.osc_clk(clk_in), .osc_clk_p(), .osc_clk_n());
  // , .freq_in(freq_in), .freq_out(freq_out));
  osc_bridge #(.diff_sel(1), .passive(1)) detector_bridge  (.osc_clk(), .osc_clk_p(clkout_p), .osc_clk_n(clkout_n));
  `else
  assign clk_in = generator_if.osc_clk;
  assign detector_if.osc_clk_p = clkout_p;
  assign detector_if.osc_clk_n = clkout_n;
  `endif
  // assign freq_in = generator_bridge.core.freq_in;
  // assign freq_out = generator_bridge.core.freq_out;
assign freq_in = generator_if.freq;
assign freq_out = detector_if.freq;
  pll pll_dut (
    .fref(freq_in),
    .fout(freq_out)
  );
  
  initial begin
    rst_n = 0;
    #5 rst_n = 1;
    $timeformat(-15, 5, " fs", 10); //Setting time precision for UVM report macros
    run_test();
  end

endmodule : top
