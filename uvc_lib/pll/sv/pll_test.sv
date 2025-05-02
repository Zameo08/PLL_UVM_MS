class test extends uvm_test;
  `uvm_component_utils(test)

  env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    ms_source_nested_seq seq = ms_source_nested_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass

// Test cho Input Threshold Voltage
class input_threshold_test extends uvm_test;
  `uvm_component_utils(input_threshold_test)

  function new(string name="input_threshold_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "input_threshold_seq.itr", 50);
    // Bật recording nếu cần (tùy thuộc vào công cụ mô phỏng)
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    input_threshold_seq seq = input_threshold_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho PLL Lock Time
class lock_time_test extends uvm_test;
  `uvm_component_utils(lock_time_test)

  function new(string name="lock_time_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    lock_time_seq seq = lock_time_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho Output Threshold Voltage
class output_threshold_test extends uvm_test;
  `uvm_component_utils(output_threshold_test)

  function new(string name="output_threshold_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "output_threshold_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    output_threshold_seq seq = output_threshold_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho Phase Noise
class phase_noise_test extends uvm_test;
  `uvm_component_utils(phase_noise_test)

  function new(string name="phase_noise_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "phase_noise_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase_noise_seq seq = phase_noise_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho Jitter
class jitter_test extends uvm_test;
  `uvm_component_utils(jitter_test)

  function new(string name="jitter_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "jitter_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    jitter_seq seq = jitter_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho Frequency Stability
class freq_stability_test extends uvm_test;
  `uvm_component_utils(freq_stability_test)

  function new(string name="freq_stability_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "freq_stability_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    freq_stability_seq seq = freq_stability_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

// Test cho Loop Bandwidth
class loop_bandwidth_test extends uvm_test;
  `uvm_component_utils(loop_bandwidth_test)

  function new(string name="loop_bandwidth_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "loop_bandwidth_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    loop_bandwidth_seq seq = loop_bandwidth_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass


class spurious_signals_test extends uvm_test;
  `uvm_component_utils(spurious_signals_test)

  function new(string name="spurious_signals_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "spurious_signals_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    spurious_signals_seq seq = spurious_signals_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass

class power_supply_sensitivity_test extends uvm_test;
  `uvm_component_utils(power_supply_sensitivity_test)

  function new(string name="power_supply_sensitivity_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "env.agent.sequencer", "power_supply_sensitivity_seq.itr", 50);
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
  endfunction

  virtual task run_phase(uvm_phase phase);
    power_supply_sensitivity_seq seq = power_supply_sensitivity_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass