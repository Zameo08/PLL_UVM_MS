class pll_bridge_proxy extends uvm_ms_proxy;
  `uvm_object_utils(pll_bridge_proxy)

  function new(string name = "");
    super.new(name);
  endfunction : new

  virtual function void config_wave(input real ampl, bias, freq, enable);
    `uvm_warning("proxy", "Function config_wave not implemented")
  endfunction

  real delay_in;
  int duration_in;
  bit sampling_do;

  bit sampling_done;
  real freq_out;
  real lock_time_out;
  real jitter_rms_out;
endclass