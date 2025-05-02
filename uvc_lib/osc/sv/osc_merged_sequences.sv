//------------------------------------------------------------------------------
//
// SEQUENCE: osc_base_seq
//
//------------------------------------------------------------------------------
 
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
