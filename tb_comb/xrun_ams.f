// This *.f file is meant to be run in the xrun_ams_sim directory
-64
-timescale 1ns/1fs
-vtimescale 1ns/1fs
-access +rwc

// options
-uvm
+UVM_VERBOSITY=UVM_HIGH
+UVM_TESTNAME=default_sequence_ms_test

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
../../uvc_lib/osc/vams/osc_bridge_core.vams

// virtual interfaces
../../uvc_lib/osc/sv/osc_if.sv
../../uvc_lib/registers/sv/registers_if.sv

// DUT
-incdir ../../src_vams/
../../src_vams/CP.vams
../../src_vams/frequency_divider.vams
../../src_vams/PFD.vams
../../src_vams/VCO.vams
../../src_vams/pll.vams
../../src_dig/registers.sv

// // assertion
// -incdir ../../sva/
// ../../sva/pll_sva.sv

-define UVM_AMS
-incdir ../
../top.sv
-top top
+SVSEED=random

//-coverage U -covoverwrite
-input /home/huyen_k66/Documents/PLL_UVM_MS/tb_comb/probes_ams.tcl
-run 
//-gui
-exit

../amscf.scs

//RNM Coercion is used to change the nettypes of top.{clk_in,clkout_p, clkout_n} from "wire" to "wreal4state"
//This is a Cadence Xcelium Mixed Signal App feature, and for non-Cadence simulators, will need either:
//* an equivalent feature to coercion, OR
//* an update to the ../top.sv and ../../uvc_lib/osc/sv/osc_bridge.sv files
-rnm_coerce detailed


// // This *.f file is meant to be run in the xrun_ams_sim directory
// -64
// -timescale 1ns/1fs
// -vtimescale 1ns/1fs
// -access +rwc

// // options
// -uvm
// +UVM_VERBOSITY=UVM_HIGH
// +UVM_TESTNAME=default_sequence_ms_test

// // include directories
// -incdir ../../uvc_lib/osc/sv/
// -incdir ../../uvc_lib/registers/sv/
// -incdir ../../includes/
// -incdir ../

// // compile files (reordered for dependency resolution)
// ../../includes/uvm_ms_pkg.sv
// ../../uvc_lib/osc/sv/osc_if.sv
// ../../uvc_lib/registers/sv/registers_if.sv
// ../../uvc_lib/osc/sv/osc_pkg.sv
// ../../uvc_lib/registers/sv/registers_pkg.sv


// // Analog resource
// ../../uvc_lib/osc/sv/osc_bridge.sv
// ../../uvc_lib/osc/vams/osc_bridge_core.vams

// // DUT
// -incdir ../../src_vams/
// ../../src_dig/registers.sv
// ../../src_vams/CP.vams
// ../../src_vams/frequency_divider.vams
// ../../src_vams/PFD.vams
// ../../src_vams/VCO.vams
// ../../src_vams/pll.vams

// // Testbench files
// ../pll_scoreboard.sv
// ../pll_tb.sv
// ../test_lib.sv

// // Top module
// ../top.sv
// -top top
// +SVSEED=random

// -define UVM_AMS

// //-coverage U -covoverwrite
// -input /home/huyen_k66/Documents/PLL_UVM_MS/tb_comb/probes_ams.tcl
// -run 
// //-gui
// -exit

// ../amscf.scs

// // RNM Coercion
// -rnm_coerce detailed