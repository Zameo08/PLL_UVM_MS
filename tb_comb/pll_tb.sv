// tb class for digital version of frequency adapter
class pll_tb extends uvm_env;

  // component macro
  `uvm_component_utils(pll_tb)

  registers_env registers;
  osc_env freq_generator;
  osc_env freq_detector; 
  
  pll_scoreboard pll_sb;

  // Constructor
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    `uvm_info("MSG","In the build phase",UVM_MEDIUM)
    
    // set up virtual interfaces for UVCs and scoreboard
    uvm_config_db#(virtual osc_if)::set(this,"freq_generator*","vif", top.generator_if);
    uvm_config_db#(virtual osc_if)::set(this,"freq_detector*", "vif", top.detector_if);
    uvm_config_db#(virtual registers_if)::set(this,"registers.reg_agent.*", "reg_vif", top.reg_if);

    // config the value of diff_sel for freq_generator to 0 - single-ended clock generation
    uvm_config_int::set(this,"freq_generator.agent.*","diff_sel", 0); 
    // config the value of diff_sel for freq_detector to 1 - differential clock detection
    uvm_config_int::set(this,"freq_detector.agent.*","diff_sel", 1);
    
    super.build_phase(phase);
    
    // create the envs for the generator, detector, registers and scoreboard
    freq_generator = osc_env::type_id::create("freq_generator",  this);
    freq_detector  = osc_env::type_id::create("freq_detector",   this);
    registers      = registers_env::type_id::create("registers", this);
    pll_sb   = pll_scoreboard::type_id::create("pll_sb",   this);

  endfunction : build_phase

  // UVM connect_phase
  function void connect_phase(uvm_phase phase);
    // Connect the TLM ports from the UVCs to the scoreboard
    registers.reg_agent.monitor.item_collected_port.connect(pll_sb.sb_registers_in);
    freq_generator.agent.monitor.item_collected_port.connect(pll_sb.sb_osc_gen);
    freq_detector.agent.monitor.item_collected_port.connect(pll_sb.sb_osc_det);
  endfunction : connect_phase

endclass : pll_tb

// tb class for SVRNM and VAMS version of frequency adapter
class pll_ms_tb extends pll_tb;

  // component macro
  `uvm_component_utils(pll_ms_tb)
  
  //pll_ms_scoreboard pll_sb;

  // Constructor
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    `ifdef UVM_AMS
    // set up brdige proxy pointer references to generator and detector UVCs
    uvm_config_db #(osc_bridge_proxy)::set(this,"freq_generator.agent.*","bridge_proxy", top.generator_bridge.__uvm_ms_proxy);
    uvm_config_db #(osc_bridge_proxy)::set(this,"freq_detector.agent.*","bridge_proxy", top.detector_bridge.__uvm_ms_proxy);
    `endif
    
    // override driver, monitor, and scoreboard with UVM-AMS versions
    set_type_override_by_type(osc_transaction::get_type(),osc_ms_transaction::get_type());
    set_type_override_by_type(osc_driver::get_type(),osc_ms_source_driver::get_type());
    set_type_override_by_type(osc_monitor::get_type(),osc_ms_source_monitor::get_type());
    set_type_override_by_type(pll_scoreboard::get_type(),pll_ms_scoreboard::get_type());
    
    super.build_phase(phase);

  endfunction 
  
endclass : pll_ms_tb
