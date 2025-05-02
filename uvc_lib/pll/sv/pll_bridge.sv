module pll_bridge import cds_rnm_pkg::*; (
    input wire fref,
    output wire fout
);

import uvm_pkg::*;
import uvm_ms_pkg::*;
`include "uvm_macros.svh"
`include "uvm_ms.svh"

import pll_pkg::*;

parameter bit passive = 0;
class proxy extends pll_bridge_proxy;
    function new(string name = "");
        super.new(name);
    endfunction //new()

    function void config_wave(input real ampl, bias, freq, enable);
      core.ampl_in = ampl;
      core.bias_in = bias;
      core.freq_in = freq;
      core.enable = enable;
    endfunction
endclass //proxy extends pll_bridge_proxy

proxy __uvm_ms_proxy = new("__uvm_ms_proxy");

always @(__uvm_ms_proxy.delay_in, __uvm_ms_proxy.duration_in, __uvm_ms_proxy.sampling_do) begin
  core.delay_in = __uvm_ms_proxy.delay_in;
  core.duration_in = __uvm_ms_proxy.duration_in;
  core.sampling_do = __uvm_ms_proxy.sampling_do;
end

always_comb begin
  __uvm_ms_proxy.sampling_done = core.sampling_done;
  __uvm_ms_proxy.freq_out = core.freq_out;
  __uvm_ms_proxy.lock_time_out = core.lock_time_out;
  __uvm_ms_proxy.jitter_rms_out = core.jitter_rms_out;
end

pll_bridge_core #(.passive(passive)) core (
  .fref(fref),
  .fout(fout)
);

endmodule