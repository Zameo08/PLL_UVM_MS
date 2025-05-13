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
    freq inside {[29e6 : 31e6]};
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

    //drive
    rand real ampl; // amplifier
    rand real bias;
    rand bit enable;

    //measurement
    rand real delay;
    rand int duration; // thoi gian do (so chu ky)

    real measured_freq;
    real lock_time;
    real jitter_rms;
    real phase_error;

    `uvm_object_utils_begin(osc_ms_transaction)
        `uvm_field_enum(osc_ms_data_type_e, data_type, UVM_DEFAULT)
        `uvm_field_real(ampl, UVM_DEFAULT)
        `uvm_field_real(bias, UVM_DEFAULT)
        `uvm_field_int(enable, UVM_DEFAULT)
        `uvm_field_real(delay, UVM_DEFAULT)
        `uvm_field_int(duration, UVM_DEFAULT)
        `uvm_field_real(measured_freq, UVM_DEFAULT)
        `uvm_field_real(lock_time, UVM_DEFAULT)
        `uvm_field_real(jitter_rms, UVM_DEFAULT)
        `uvm_field_real(phase_error, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint default_drive_trans {
        // ampl inside {[0.95:1.65]}; // reference amplifier
    ampl > 0.95;
    ampl < 1.65;
        bias inside {[-0.5:0.5]}; // reference bias
        enable dist {1'b0 := 1, 1'b1 := 5};
    }

    constraint default_measurement_trans {
        // duration inside {[20:32]}; // number of measurement period
        // delay inside {[0.0:1.0]};  // delay before measurement
        duration > 20;
        duration < 32;
        delay > 0.0;
        delay < 1.0;
      }
    function new(string name = "osc_ms_transaction");
        super.new(name);
    endfunction //new()

endclass