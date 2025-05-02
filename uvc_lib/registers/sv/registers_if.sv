// PLL Register UVC Interface
timeunit 1ns;
timeprecision 1fs;
interface registers_if ();



import uvm_pkg::*;
`include "uvm_macros.svh"

// Actual register interface signals
bit [7:0] addr;
bit [7:0] wdata;
bit       wen;
bit       ren;

bit [7:0] rdata;

// Output values to drive DUT
bit [7:0] div_cfg;
bit [3:0] vco_gain;
bit [1:0] lpf_rp;
bit [1:0] lpf_cp;
bit [1:0] lpf_c2;
bit       enable_pll;

// Signals for transaction tracing
event monstart, drvstart;
logic sig_en;

// Gets a packet and drive it into the DUT
task send_to_dut(
  input bit [7:0] addr_seq,
  input bit [7:0] wdata_seq,
  input bit       wen_seq,
  input bit       ren_seq
);
`uvm_info("REGISTERS_IF", "sending packet to DUT", UVM_HIGH)
  // start to send packet
  @(posedge sig_en);
  // drive the DUT with packet
  addr  = addr_seq;
  wdata = wdata_seq;
  wen   = wen_seq;
  ren   = ren_seq;
  ->drvstart;
endtask : send_to_dut

// collect packets
task collect_packet(
  output bit [7:0] addr_seq,
  output bit [7:0] wdata_seq,
  output bit       wen_seq,
  output bit       ren_seq
);
  #100ps; // collect packet every 100ps
  `uvm_info("REGISTERS_IF", "Collecting packet from interface", UVM_HIGH)
  addr_seq  = addr;
  wdata_seq = wdata;
  wen_seq   = wen;
  ren_seq   = ren;

endtask : collect_packet

endinterface : registers_if
