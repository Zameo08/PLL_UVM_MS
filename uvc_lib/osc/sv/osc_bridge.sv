// Bridge for analog clock UVC in UVM-AMS

module osc_bridge import cds_rnm_pkg::*; (
  input  wire osc_clk,
  output wire osc_clk_p,
  output wire osc_clk_n
  // ,
  // input wire freq_in,
  // output wire freq_out
  );

  //UVM + MS extras
  import uvm_pkg::*;
  import uvm_ms_pkg::*;
  `include "uvm_macros.svh"
  `include "uvm_ms.svh"
  
  //UVM package for this component
  import osc_pkg::*;

  //Selection bit to choose between single-ended clock and differential clock
  parameter bit diff_sel = 0;
  parameter passive = 0;
  
  //Class proxy extends the osc_bridge_proxy included in osc_pkg.sv
  //The implementation for the config_wave push function is defined here
  class proxy extends osc_bridge_proxy;
    
    function new(string name = "");
      super.new(name);
    endfunction : new
  
    function void config_wave(input real ampl, bias, freq, enable);
      core.ampl_in  = ampl;
      core.bias_in  = bias;
      core.freq_in  = freq;
      core.enable   = enable;
    endfunction
  endclass
  
  proxy __uvm_ms_proxy = new("__uvm_ms_proxy");
  
  //Connections from proxy to core
  always @(__uvm_ms_proxy.delay_in, __uvm_ms_proxy.duration_in, __uvm_ms_proxy.sampling_do) begin
    core.delay_in = __uvm_ms_proxy.delay_in;
    core.duration_in = __uvm_ms_proxy.duration_in;
    core.sampling_do = __uvm_ms_proxy.sampling_do;
  end
  
  //Connections from core to proxy
  always_comb begin  
    __uvm_ms_proxy.sampling_done = core.sampling_done;
    __uvm_ms_proxy.ampl_out = core.ampl_out;
    __uvm_ms_proxy.bias_out = core.bias_out;
    __uvm_ms_proxy.freq_out = core.freq_out;
  end
  
  //Analog resource instantiation
  osc_bridge_core #(.diff_sel(diff_sel), .passive(passive)) core (
    .osc_clk(osc_clk),
    .osc_clk_p(osc_clk_p),
    .osc_clk_n(osc_clk_n)
    // , 
    // .freq_in(freq_in),
    // .freq_out(freq_out)
    );

endmodule 
