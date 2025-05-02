// Bring in the rest of the library (macros)
`include "uvm_macros.svh"

package osc_pkg;

  // UVM class library compiled in a package
  import uvm_pkg::*;
  import uvm_ms_pkg::*;
  `include "osc_types.sv"

  // transaction
  `include "osc_transaction.sv"

  // bridge proxy
  `include "osc_bridge_proxy.sv"

  // UVC
  `include "osc_sequencer.sv"
  `include "osc_monitor.sv"
  `include "osc_driver.sv"
  `include "osc_agent.sv"
  `include "osc_merged_sequences.sv"
  `include "osc_env.sv"

endpackage : osc_pkg
