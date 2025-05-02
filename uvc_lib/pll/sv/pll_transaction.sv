class pll_transaction extends uvm_sequence_item;
    rand real freq; // reference frequency

    `uvm_object_utils_begin(pll_transaction)
        `uvm_field_real(freq, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint default_freq_c {
        freq inside {[25e6:34e6]};
    }

    function new(string name = "pll_transaction");
        super.new(name);
    endfunction //new()
endclass //pll_transaction extends uvm_sequence_item

class pll_ms_transaction extends pll_transaction;
    rand pll_ms_data_type_e data_type;

    //drive
    rand real ampl; // amplifier
    rand real bias;
    rand bit enable;

    //measurement
    real delay;
    rand int duration; // thoi gian do (so chu ky)

    real measured_freq;
    real lock_time;
    real jitter_rms;
    real phase_error;

    `uvm_object_utils_begin(pll_ms_transaction)
        `uvm_field_enum(pll_ms_data_type_e, UVM_DEFAULT)
        `uvm_field_real(ampl, UVM_DEFAULT)
        `uvm_field_real(bias, UVM_DEFAULT)
        `uvm_field_int(enable, UVM_DEFAULT)
        `uvm_filed_real(delay, UVM_DEFAULT)
        `uvm_filed_int(duration, UVM_DEFAULT)
        `uvm_filed_real(measured_freq, UVM_DEFAULT)
        `uvm_filed_real(lock_time, UVM_DEFAULT)
        `uvm_filed_real(jitter_rms, UVM_DEFAULT)
        `uvm_filed_real(phase_error, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint default_drive_trans {
        ampl inside {[0.95:1.65]}; // reference amplifier
        bias inside {[-0.5:0.5]}; // reference bias
        enable dist {1'b0 := 1, 1'b1 := 5};
    }

    constraint default_measurement_trans {
        duration inside {[20:32]}; // number of measurement period
        delay inside {[0.0:1.0]};  // delay before measurement
      }
    function new(string name = "pll_ms_transaction");
        super.new(name);
    endfunction //new()

endclass //pll_ms_transaction extends pll_transaction