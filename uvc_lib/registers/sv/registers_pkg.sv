package registers_pkg;
  import uvm_pkg::*;

  typedef uvm_config_db#(virtual registers_if) registers_vif_config;

  `include "uvm_macros.svh"
  //`include "registers_if.sv"
  `include "registers_types.sv"
  `include "registers_packet.sv"
  `include "registers_monitor.sv"
  `include "registers_sequencer.sv"
  `include "registers_seqs.sv"
  `include "registers_driver.sv"
  `include "registers_agent.sv"
  `include "registers_env.sv"

endpackage: registers_pkg
