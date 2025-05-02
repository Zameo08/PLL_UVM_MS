// The register UVC packet file

class registers_packet extends uvm_sequence_item;
	rand bit [7:0] addr;
	rand bit [7:0] wdata;
	rand bit   wen;
	rand bit   ren;
	bit lpf_rp;
	bit lpf_cp;
	bit lpf_c2;
	bit vco_gain;
	bit div_cfg;
  
  // Enable automation of the packet's fields
	`uvm_object_utils_begin(registers_packet)
	`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_field_int(wdata, UVM_ALL_ON)
	`uvm_field_int(wen, UVM_ALL_ON)
	`uvm_field_int(ren, UVM_ALL_ON)
	
	`uvm_object_utils_end
	// constructor
	function new(string name = "register_packet");
		super.new(name);
	endfunction
	
	// define packet constraints
	constraint reg_address { addr dist { [0:1]:=3, [2:7]:/1}; }
	constraint wdata_digital{ wdata dist { [0:3]:/1, [4:7]:=5, [8'b00001000:8'b11111111]:/1 }; }

endclass: registers_packet

