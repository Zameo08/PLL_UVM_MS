class pll_base_test extends uvm_test;

  `uvm_component_utils(pll_base_test)

  pll_tb tb;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Configure the agents
    uvm_config_int::set( this, "tb.freq_generator.agent","is_active", UVM_ACTIVE);
    uvm_config_int::set( this, "tb.freq_detector.agent","is_active", UVM_PASSIVE);
    // Enable transaction recording for everything
    uvm_config_int::set( this, "*", "recording_detail", 1);
    // Create the testbench
    tb = pll_tb::type_id::create("tb", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
   endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  task run_phase(uvm_phase phase);
    //uvm_objection obj = phase.get_objection();
    //obj.set_drain_time(this, 8.1ns); 
    // Note: The drain time is equal to the input clock period in order to monitor the last packet
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    // configuration checker
    check_config_usage();
  endfunction

endclass : pll_base_test

//----------------------------------------------------------------
//
// TEST: default_sequence_test - sets the default sequences
//
//----------------------------------------------------------------
class default_sequence_test extends pll_base_test;
  `uvm_component_utils(default_sequence_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",osc_nested_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 

endclass

class default_sequence_ms_test extends pll_base_test;
  `uvm_component_utils(default_sequence_ms_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",osc_ms_source_nested_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 

endclass


class input_threshold_test extends pll_base_test;
  `uvm_component_utils(input_threshold_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",input_threshold_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass

class lock_time_test extends pll_base_test;
  `uvm_component_utils(lock_time_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_freq", 0);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_lock_time", 1);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_jitter", 0);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_phase_error", 0);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",lock_time_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass

class output_threshold_test extends pll_base_test;
  `uvm_component_utils(output_threshold_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_freq", 1);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_lock_time", 0);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_jitter", 0);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_phase_error", 0);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",output_threshold_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass

class phase_error_test extends pll_base_test;
  `uvm_component_utils(phase_error_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_freq", 0);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_lock_time", 0);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_jitter", 0);
  uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_phase_error", 1);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",phase_error_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass

class jitter_test extends pll_base_test;
  `uvm_component_utils(jitter_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_freq", 0);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_lock_time", 0);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_jitter", 1);
    uvm_config_db#(bit)::set(this, "tb.freq_detector.agent.monitor", "measure_phase_error", 0);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",jitter_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass

class power_supply_test extends pll_base_test;
  `uvm_component_utils(power_supply_test)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    set_type_override_by_type(pll_tb::get_type(),pll_ms_tb::get_type());
    super.build_phase(phase);
    // Set the default sequence for the in_adpt and out_adpt
    uvm_config_wrapper::set(this,"tb.freq_generator.agent.sequencer.run_phase", "default_sequence",power_supply_seq::get_type());
    uvm_config_wrapper::set(this,"tb.registers.reg_agent.sequencer.run_phase", "default_sequence",registers_config::get_type());
  endfunction 
endclass