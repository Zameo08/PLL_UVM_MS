//------------------------------------------------------------------------------
//
// CLASS: osc_transaction
//
//------------------------------------------------------------------------------

class osc_transaction extends uvm_sequence_item;
          
  rand real freq; // frequency of input clock
  bit diff_sel;
 
  `uvm_object_utils_begin(osc_transaction)
    `uvm_field_real(freq, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constraints go here
  constraint default_freq_c { 
    freq inside {[3e7 : 32e6]};
  }

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "osc_transaction");
    super.new(name);
  endfunction : new

endclass : osc_transaction

//------------------------------------------------------------------------------
//
// CLASS: osc_ms_transaction
//
//------------------------------------------------------------------------------

class osc_ms_transaction extends osc_transaction;

  rand osc_ms_data_type_e data_type;

  // Drive fields
  rand real ampl;  //ampl_adj
  rand real bias;  // bias analog
  rand bit enable;  //en_mux

  //Measurment fields
  rand real delay;    //Delay in ns
  rand int  duration;

  `uvm_object_utils_begin(osc_ms_transaction)
    `uvm_field_enum(osc_ms_data_type_e, data_type, UVM_DEFAULT)
    `uvm_field_real(ampl, UVM_DEFAULT)
    `uvm_field_real(bias, UVM_DEFAULT)
    `uvm_field_int(enable, UVM_DEFAULT)
    `uvm_field_real(delay, UVM_DEFAULT)
    `uvm_field_int(duration, UVM_DEFAULT)
  `uvm_object_utils_end

  // Constraints go here
  // To override, use the same constraint name or TCL to disable
  constraint default_drive_trans_c {
    ampl > 0.95;
    ampl < 1.65;
    bias inside {[-0.05:0.5]};
    enable dist { 1'b0 := 1 , 1'b1 := 5 };
  }
  constraint default_measurement_trans_c {
    duration > 20;
    duration < 32;
    delay > 0.0;
    delay < 1.0;
  }

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "unnamed-osc_ms_transaction");
    super.new(name);
  endfunction : new

endclass : osc_ms_transaction

