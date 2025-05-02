class registers_base_seq extends uvm_sequence #(registers_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(registers_base_seq)

  // Constructor
  function new(string name="registers_base_seq");
    super.new(name);
  endfunction

  task set_lpf_config(
    input int rp,
    input int cp,
    input int c2
  );
    // LPF RP
    case (rp)
      4700: begin
        req.lpf_rp = 2'b00;
        `uvm_info("SEQ", $sformatf("Set lpf_rp = 4700 Ohm"), UVM_LOW);
      end
      6500: begin
        req.lpf_rp = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_rp = 6500 Ohm"), UVM_LOW);
      end
      8200: begin
        req.lpf_rp = 2'b10;
        `uvm_info("SEQ", $sformatf("Set lpf_rp = 8200 Ohm"), UVM_LOW);
      end
      10000: begin
        req.lpf_rp = 2'b11;
        `uvm_info("SEQ", $sformatf("Set lpf_rp = 10000 Ohm"), UVM_LOW);
      end
      default: begin
        `uvm_warning("SEQ", $sformatf("Unsupported RP value: %0d Ohm. Using default = 6500", rp));
        req.lpf_rp = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_rp = 6500 Ohm (default)"), UVM_LOW);
      end
    endcase
  
    // LPF CP
    case (cp)
      50: begin
        req.lpf_cp = 2'b00;
        `uvm_info("SEQ", $sformatf("Set lpf_cp = 50 pF"), UVM_LOW);
      end
      100: begin
        req.lpf_cp = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_cp = 100 pF"), UVM_LOW);
      end
      150: begin
        req.lpf_cp = 2'b10;
        `uvm_info("SEQ", $sformatf("Set lpf_cp = 150 pF"), UVM_LOW);
      end
      200: begin
        req.lpf_cp = 2'b11;
        `uvm_info("SEQ", $sformatf("Set lpf_cp = 200 pF"), UVM_LOW);
      end
      default: begin
        `uvm_warning("SEQ", $sformatf("Unsupported CP value: %0d pF. Using default = 100", cp));
        req.lpf_cp = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_cp = 100 pF (default)"), UVM_LOW);
      end
    endcase
  
    // LPF C2
    case (c2)
      5: begin
        req.lpf_c2 = 2'b00;
        `uvm_info("SEQ", $sformatf("Set lpf_c2 = 5 pF"), UVM_LOW);
      end
      10: begin
        req.lpf_c2 = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_c2 = 10 pF"), UVM_LOW);
      end
      15: begin
        req.lpf_c2 = 2'b10;
        `uvm_info("SEQ", $sformatf("Set lpf_c2 = 15 pF"), UVM_LOW);
      end
      20: begin
        req.lpf_c2 = 2'b11;
        `uvm_info("SEQ", $sformatf("Set lpf_c2 = 20 pF"), UVM_LOW);
      end
      default: begin
        `uvm_warning("SEQ", $sformatf("Unsupported C2 value: %0d pF. Using default = 10", c2));
        req.lpf_c2 = 2'b01;
        `uvm_info("SEQ", $sformatf("Set lpf_c2 = 10 pF (default)"), UVM_LOW);
      end
    endcase
  
    `uvm_info("SEQ", $sformatf("Final LPF config: Rp = %0d, Cp = %0d, C2 = %0d", rp, cp, c2), UVM_LOW);
  endtask

  task set_div_config(input int div_val);
    if (div_val > 0 && div_val <= 255) begin
      req.div_cfg = div_val;
      `uvm_info("SEQ", $sformatf("Set div_cfg = %0d", div_val), UVM_LOW);
    end
    else begin
      `uvm_warning("SEQ", $sformatf("Invalid divider value: %0d. Using default = 8", div_val));
      req.div_cfg = 8;
      `uvm_info("SEQ", $sformatf("Set div_cfg = 8 (default)"), UVM_LOW);
    end
endtask
  
task set_vco_gain(input int kvco);
  case (kvco)
    100: begin
      req.vco_gain = 4'b0001;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 100 MHz/V"), UVM_LOW);
    end
    200: begin
      req.vco_gain = 4'b0010;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 200 MHz/V"), UVM_LOW);
    end
    300: begin
      req.vco_gain = 4'b0011;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 300 MHz/V"), UVM_LOW);
    end
    400: begin
      req.vco_gain = 4'b0100;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 400 MHz/V"), UVM_LOW);
    end
    500: begin
      req.vco_gain = 4'b0101;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 500 MHz/V"), UVM_LOW);
    end
    600: begin
      req.vco_gain = 4'b0110;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 600 MHz/V"), UVM_LOW);
    end
    700: begin
      req.vco_gain = 4'b0111;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 700 MHz/V"), UVM_LOW);
    end
    800: begin
      req.vco_gain = 4'b1000;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 800 MHz/V"), UVM_LOW);
    end
    default: begin
      `uvm_warning("SEQ", $sformatf("Unsupported Kvco: %0d MHz/V. Using default = 600", kvco));
      req.vco_gain = 4'b0110;
      `uvm_info("SEQ", $sformatf("Set vco_gain = 600 MHz/V (default)"), UVM_LOW);
    end
  endcase
endtask


  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM);
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM);
    end
  endtask : post_body

endclass : registers_base_seq


// packets with SPEC value
class registers_config extends registers_base_seq;
  `uvm_object_utils(registers_config)

  function new(string name="registers_config");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing PLL CONFIG", UVM_LOW);
  repeat(20) begin
    `uvm_create(req)
  // set PLL config
    set_div_config(64);              // Set divider = 64
    set_vco_gain(600);               // Set VCO gain = 600 MHz/V
    set_lpf_config(6500, 100, 10);   // Set LPF: Rp = 6.5kΩ, Cp = 100pF, C2 = 10pF

    start_item(req);
    finish_item(req);
    
  end

    //`uvm_do_with(req, {addr==8'h01; wdata==8'h04;}) // Enable mux + div-by-4
  endtask
endclass : registers_config


// task set_lpf_config(
//   input int rp,
//   input int cp,
//   input int c2 
// );
//   case (rp)
//       4700: req.lpf_rp = 2'b00;
//       6500: req.lpf_rp = 2'b01;  
//       8200: req.lpf_rp = 2'b10;  
//       10000: req.lpf_rp = 2'b11;  
//     default: begin
//       `uvm_warning("SEQ", $sformatf("Unsupported RP value: %0d Ohm", rp));
//       req.lpf_rp = 2'b01; // 6.5k
//     end
//   endcase

//   case (cp)
//       50: req.lpf_cp = 2'b00;  
//       100: req.lpf_cp = 2'b01;  
//       150: req.lpf_cp = 2'b10;  
//       200: req.lpf_cp = 2'b11;  
//     default: begin
//       `uvm_warning("SEQ", $sformatf("Unsupported CP value: %0d pF", cp));
//       req.lpf_cp = 2'b01; // 100pF
//     end
//   endcase

//   case (c2)
//       5: req.lpf_c2 = 2'b00;  
//       10: req.lpf_c2 = 2'b01;  
//       15: req.lpf_c2 = 2'b10;  
//       20: req.lpf_c2 = 2'b11;  
//     default: begin
//       `uvm_warning("SEQ", $sformatf("Unsupported RP value: %0d pF", c2));
//       req.lpf_c2 = 2'b01; // 10pF
//     end
//   endcase
// `uvm_info("SEQ", $sformatf("Set LPF config: Rp = %0d Ohm, Cp = %0d pF, C2 = %0d pF", rp, cp, c2), UVM_LOW);
// endtask //set_lpf_config

// task set_div_config (input int div_val);
//   if (div_val > 0 && div_val <= 255) begin
//     req.div_cfg = div_val;
//     `uvm_info("SEQ", $sformatf("Set div_cfg = %0d", div_val), UVM_LOW);
//   end
//   else begin
//     `uvm_warning("SEQ", $sformatf("Invalid divider value: %0d. Using default = 8", div_val));
//     req.div_cfg = 8;
//   end
// endtask //set_div_config

// task set_vco_gain(input int kvco);
//   case (kvco)
//     100: req.vco_gain = 4'b0001;
//     200: req.vco_gain = 4'b0010;
//     300: req.vco_gain = 4'b0011;
//     400: req.vco_gain = 4'b0100;
//     500: req.vco_gain = 4'b0101;
//     600: req.vco_gain = 4'b0110;
//     700: req.vco_gain = 4'b0111;
//     800: req.vco_gain = 4'b1000;
//     default: begin
//       `uvm_warning("SEQ", $sformatf("Unsupported Kvco: %0d MHz/V. Using default = 600 MHz/V", kvco));
//       req.vco_gain = 4'b0101;
//     end
//   endcase
//   `uvm_info("SEQ", $sformatf("Set VCO gain = %0d MHz/V", kvco), UVM_LOW);
// endtask