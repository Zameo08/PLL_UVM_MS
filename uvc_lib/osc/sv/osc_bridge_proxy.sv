// ==================================================
// Proxy class to be extended in the VAMS wrapper
// It allows UVM components to access VAMS API 
// by passing a handle to the proxy instance via
// uvm_config_db. Class is declared virtual so it 
// cannot be instantiated, it must be derived.
// It is possible to derive from uvm_component if UVM
// phase information required in the AMS bridge scope
// Must extend from uvm_report_object so the reporting
// from the analog resource goes to context
// ==================================================
//
// Not done as Virtual class so proxy is registered with UVM factory.
// Downside is user must remember to extend and override method as they
// only report issues at runtime when they are called. 

class osc_bridge_proxy extends uvm_ms_proxy;
  `uvm_object_utils(osc_bridge_proxy)
  
  function new(string name = "");
    super.new(name);
  endfunction : new
  
  //Protoype for push function to core
  virtual function void config_wave(input real ampl, bias, freq, enable);
    `uvm_warning("proxy","Function config_wave not implemented")
  endfunction
  //Signals to send to core sampler
  real   delay_in;
  int    duration_in;
  bit    sampling_do;
  //Measurements to send up reported values to monitor
  bit   sampling_done;
  real   ampl_out;
  real   bias_out;
  real   freq_out;
endclass
