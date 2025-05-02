// This *.f file is meant to be run in the xrun_dig_sim directory
-64
-timescale 1ns/1fs
-vtimescale 1ns/1fs
-access +rwc

// options
-uvm
+UVM_VERBOSITY=UVM_MEDIUM
+UVM_TESTNAME=default_sequence_test

// include directories
-incdir ../../uvc_lib/osc/sv/
-incdir ../../uvc_lib/registers/sv/
-incdir ../../includes/

// compile files
../../includes/uvm_ms_pkg.sv
../../uvc_lib/osc/sv/osc_pkg.sv
../../uvc_lib/registers/sv/registers_pkg.sv

// Analog resource
../../uvc_lib/osc/sv/osc_bridge.sv
// for SVRNM DUT
../../uvc_lib/osc/sv/osc_bridge_core.sv

// virtual interfaces
../../uvc_lib/osc/sv/osc_if.sv
../../uvc_lib/registers/sv/registers_if.sv

// DUT
-incdir ../../src_dig/
../../src_dig/buffer_dig.sv
../../src_dig/clk_driver_diff_dig.sv
../../src_dig/freq_adapter_dig.sv
../../src_dig/freq_div2_dig.sv
../../src_dig/freq_doubler_dig.sv
../../src_dig/mux4to1_dig.sv
../../src_dig/registers.sv

-incdir ../
../top.sv
-top top
+SVSEED=random

//-coverage U -covoverwrite
-input /home/huyen_k66/Documents/Cadence/UVM_MS/freq_adapter/tb_comb/probes_dig.tcl
//-input probes.tcl
-run -exit

//amscf.scs
-rnm_coerce detailed




