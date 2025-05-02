class osc_env extends uvm_env;

  // Virtual Interface variable
  virtual interface osc_if vif;
  
  // The following two bits are used to control whether checks and coverage are
  // done both in the bus monitor class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;
  
  // Components of the environment
  osc_agent agent;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(osc_env)
  	`uvm_field_object(agent, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = osc_agent::type_id::create("agent", this);
    if(!uvm_config_db#(virtual osc_if)::get(this,"","vif",vif))
	  	`uvm_error("NOVIF","virtual interface osc_if not configured")
  	else 
  	  `uvm_info("VIF_SUCCESS","virtual interface osc_if configured",UVM_MEDIUM)
  endfunction : build_phase
  
  extern protected task update_vif_enables();
  extern virtual task run_phase(uvm_phase phase);
  
endclass : osc_env

// Function to assign the checks and coverage bits
task osc_env::update_vif_enables();
  // Make assignments at time zero based upon config
  vif.has_checks <= checks_enable;
  vif.has_coverage <= coverage_enable;
  forever begin
    // Make assignments whenever enables change after time zero
    @(checks_enable || coverage_enable);
    vif.has_checks <= checks_enable;
    vif.has_coverage <= coverage_enable;
  end
endtask : update_vif_enables

// UVM run() phase
task osc_env::run_phase(uvm_phase phase);    
  fork
    update_vif_enables();
  join_none
  super.run_phase(phase);
endtask
