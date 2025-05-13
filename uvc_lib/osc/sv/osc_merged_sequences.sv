
class osc_base_seq extends uvm_sequence #(osc_transaction);
  `uvm_object_utils(osc_base_seq)
  // Constructor
  function new(string name="osc_base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass 

class osc_base_ms_seq extends uvm_sequence #(osc_ms_transaction);
  `uvm_object_utils(osc_base_ms_seq)
  
  // Constructor
  function new(string name="osc_base_ms_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass 

//------------------------------------------------------------------------------
//
// SEQUENCE: osc_nested_seq
//
//------------------------------------------------------------------------------
 
class osc_nested_seq extends osc_base_seq;
  `uvm_object_utils(osc_nested_seq)
//	real last_freq;
  // Constructor
  function new(string name="osc_nested_seq");
    super.new(name);
  endfunction

	  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("osc_nested_seq.itr", itr));
      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d osc_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.prev_freq == last_freq;});
        void'(req.randomize());
//        last_freq = req.freq;
        `uvm_send(req)
      end
    end
  endtask

endclass



//------------------------------------------------------------------------------
//
// SEQUENCE: osc_ms_source_transaction_seq
//
//------------------------------------------------------------------------------
 
class osc_ms_source_transaction_seq extends osc_base_ms_seq;
  `uvm_object_utils(osc_ms_source_transaction_seq)  
  
  // Constructor
  function new(string name="osc_ms_source_transaction_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  task body();
    begin
      `uvm_info(get_type_name(), "Running...", UVM_HIGH)
      `uvm_do_with(req, {data_type == data_type; enable == enable;})
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass 

//------------------------------------------------------------------------------
//
// SEQUENCE: osc_ms_source_nested_seq
//
//------------------------------------------------------------------------------
 
class osc_ms_source_nested_seq extends osc_base_ms_seq;
  `uvm_object_utils(osc_ms_source_nested_seq)

//  real last_freq;

  // Constructor
  function new(string name="osc_ms_source_nested_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("osc_ms_source_nested_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d osc_ms_source_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1;});
//        last_freq = req.freq;
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass


////////


class input_threshold_seq extends osc_base_ms_seq;
  `uvm_object_utils(input_threshold_seq)

//  real last_freq;

  // Constructor
  function new(string name="input_threshold_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("input_threshold_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d input_threshold_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
         for(int i = 0; i < itr; i++) begin
          `uvm_create(req)
          //enable, delay, duration are all = 0??
          void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.ampl inside {[0.8:1.2]}; req.bias inside {[-0.3:0.3]}; req.duration == 30; req.delay == 0.5;});
          `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
          `uvm_send(req)
        end
        
      end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass


class lock_time_seq extends osc_base_ms_seq;
  `uvm_object_utils(lock_time_seq)

//  real last_freq;

  // Constructor
  function new(string name="lock_time_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("lock_time_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d lock_time_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.freq inside {[25e6:30e6]}; req.duration == 30; req.delay == 0.2;});
     `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass


class output_threshold_seq extends osc_base_ms_seq;
  `uvm_object_utils(output_threshold_seq)

//  real last_freq;

  // Constructor
  function new(string name="output_threshold_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("output_threshold_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d output_threshold_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.ampl inside {[1.5:2.0]}; req.bias inside {[-0.3:0.3]}; req.duration == 30; req.delay == 0.5;});
     `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass


class phase_error_seq extends osc_base_ms_seq;
  `uvm_object_utils(phase_error_seq)

//  real last_freq;

  // Constructor
  function new(string name="phase_error_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("phase_error_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d phase_error_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.ampl inside {[0.8:1.2]}; req.freq inside {[28e6:32e6]}; req.bias inside {[-0.3:0.3]}; req.duration == 100; req.delay == 0.1;});
     `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass

class jitter_seq extends osc_base_ms_seq;
  `uvm_object_utils(jitter_seq)

//  real last_freq;

  // Constructor
  function new(string name="jitter_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("jitter_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d jitter_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.freq inside {[25e6:30e6]}; req.duration == 30; req.delay == 0.3;});
     `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass

class power_supply_seq extends osc_base_ms_seq;
  `uvm_object_utils(power_supply_seq)

//  real last_freq;

  // Constructor
  function new(string name="power_supply_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  task body();
	int itr=20;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("power_supply_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Running... (%0d power_supply_transaction sequences)",itr), UVM_HIGH)
//      last_freq = 1e6;
      for(int i = 0; i < itr; i++) begin
        `uvm_create(req)
//        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.prev_freq == last_freq;});
        void'(req.randomize() with {req.data_type == OSC_MS_DRIVE; req.enable == 1; req.freq inside {[25e6:20e6]}; req.bias inside {[-1.0:1.0]}; req.duration == 30; req.delay == 0.5;});
     `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
        `uvm_send(req)
      end
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass
