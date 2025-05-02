// =======================================================================
// Wrapper function to hook the Analog Resource digital calls to the UVM 
// reporting system. Upscoping is used so it works in various abstractions
// of the analog resource. e.g. Verilog-AMS, SystemVerilog. Input has to be 
// int and then cast to uvm_verbosity.
//
// Use the *_context() macro versions to direct messages to associated UVM
// agent since the VAMS code operates outside UVM hierarchy
//
// New names used instead of `uvm_* macros as these are based on class 
// hierarchy.
//
// =======================================================================
`ifndef uvm_ms_info   
    `define uvm_ms_info(id,message,uvm_verbosity) uvm_ms_info   (id,message,uvm_verbosity);
`endif    
`ifndef uvm_ms_warning
    `define uvm_ms_warning(id,message)            uvm_ms_warning(id,message);
`endif    
`ifndef uvm_ms_error
    `define uvm_ms_error(id,message)              uvm_ms_error  (id,message);
`endif
`ifndef uvm_ms_fatal
    `define uvm_ms_fatal(id,message)              uvm_ms_fatal  (id,message);
`endif

function void uvm_ms_info(string id, string message, int verbosity_level);   
  `uvm_info_context(id,message,uvm_verbosity'(verbosity_level),__uvm_ms_proxy)
endfunction: uvm_ms_info
function void uvm_ms_warning(string id, string message);
  `uvm_warning_context(id,message,__uvm_ms_proxy)
endfunction: uvm_ms_warning
function void uvm_ms_error(string id, string message);  
  `uvm_error_context(id,message,__uvm_ms_proxy)
endfunction: uvm_ms_error
function void uvm_ms_fatal(string id, string message);
  `uvm_fatal_context(id,message,__uvm_ms_proxy)
endfunction:uvm_ms_fatal
