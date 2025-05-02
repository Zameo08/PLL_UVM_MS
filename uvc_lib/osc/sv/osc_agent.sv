//------------------------------------------------------------------------------
//
// CLASS: osc_agent
//
//------------------------------------------------------------------------------

class osc_agent extends uvm_agent;

  osc_monitor monitor;
  osc_sequencer sequencer;
  osc_driver driver;
  
  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(osc_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = osc_monitor::type_id::create("monitor", this);
    if(is_active == UVM_ACTIVE) begin
      sequencer = osc_sequencer::type_id::create("sequencer", this);
      driver = osc_driver::type_id::create("driver", this);
    end
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  // UVM connect() phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
      // Binds the driver to the sequencer using consumer-producer interface
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction 

endclass : osc_agent
