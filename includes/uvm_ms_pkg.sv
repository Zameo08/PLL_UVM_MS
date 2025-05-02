// =======================================================================
// Template Proxy class for uvm-ms that extend uvm_report_object
// =======================================================================
`ifndef UVM_MS_PKG_SV
`define UVM_MS_PKG_SV
 
`include "uvm_macros.svh"
 
package uvm_ms_pkg;
   import uvm_pkg::*;
  
   class uvm_ms_proxy extends uvm_report_object;
     `uvm_object_utils(uvm_ms_proxy)
 
     function new(string name = "");
       super.new(name);
     endfunction : new
 
     //Could have some base function like get/setParameters
 
   endclass : uvm_ms_proxy
 
endpackage : uvm_ms_pkg
 
`endif