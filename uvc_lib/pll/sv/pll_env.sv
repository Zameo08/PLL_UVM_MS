class pll_env extends uvm_env;

  virtual interface pll_if vif;

  bit checks_enable = 1;
  bit coverage_enable = 1;

  pll_agent agent;

  `uvm_component_utils_begin(pll_env)
    `uvm_field_object(agent, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = pll_agent::type_id::create("agent", this);
    if (!uvm_config_db#(virtual pll_if)::get(this, "", "vif", vif))
      `uvm_error("NOVIF", "virtual interface pll_if not configured")
    else
      `uvm_info("VIF_SUCCESS", "virtual interface pll_if configured", UVM_MEDIUM)
  endfunction : build_phase

  task update_vif_enables();
    vif.has_checks <= checks_enable;
    vif.has_coverage <= coverage_enable;
    forever begin
      @(checks_enable || coverage_enable);
      vif.has_checks <= checks_enable;
      vif.has_coverage <= coverage_enable;
    end
  endtask : update_vif_enables

  task run_phase(uvm_phase phase);
    fork
      update_vif_enables();
    join_none
    super.run_phase(phase);
  endtask

endclass : pll_env