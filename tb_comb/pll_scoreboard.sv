class pll_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(pll_scoreboard)

  //typedef enum bit {COV_ENABLE, COV_DISABLE} cover_e;
  cover_e coverage_control = COV_ENABLE;

  // TLM analysis ports
  `uvm_analysis_imp_decl(_registers)
  `uvm_analysis_imp_decl(_osc_gen)
  `uvm_analysis_imp_decl(_osc_det)

  uvm_analysis_imp_registers #(registers_packet, pll_scoreboard) sb_registers_in;
  uvm_analysis_imp_osc_gen #(osc_transaction, pll_scoreboard) sb_osc_gen;
  uvm_analysis_imp_osc_det #(osc_transaction, pll_scoreboard) sb_osc_det;

  // Scoreboard statistics
  int reg_packets_in, reg_in_drop;
  int freq_generator_packets_in, freq_generator_in_drop;
  int freq_detector_packets_in, freq_detector_in_drop;
  int num_match, total_match_check, in_dropped, num_mismatch;

  // Variables for coverage and comparison
  real freq; // Input frequency from freq_generator
  real freq_out; // Output frequency from freq_detector
  real freq_tol = 0.01; // 1% tolerance for frequency comparison

  // Register storage
  bit [7:0] INT_REG [0:3]; // Store register values
  bit enable_pll; // PLL enable signal

  // Queue for storing input frequencies
  real freq_in_reg[$];

  // Variable for comparison result
  bit match;

  // Covergroup for input frequency
  covergroup input_sig_cg;
    option.per_instance = 1;
    freq_cov: coverpoint freq {
      bins DC         = { [0       : 9e5   ] };
      bins Hz         = { [9e5     : 10e3  ] };
      bins KHz        = { [10e3    : 10e6  ] };
      bins MHz        = { [10e6    : 10e7  ] };
      bins TenMHz     = { [10e7    : 10e8  ] };
      bins HundredMHz = { [10e8    : 10e9  ] };
      bins GHz        = { [10e9    : 10e10 ] };
      bins Max        = { [10e10   : $     ] };
    }
  endgroup

  // Constructor
  function new(string name = "pll_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    sb_registers_in = new("sb_registers_in", this);
    sb_osc_gen = new("sb_osc_gen", this);
    sb_osc_det = new("sb_osc_det", this);
    if (coverage_control == COV_ENABLE) begin
      input_sig_cg = new();
      input_sig_cg.set_inst_name({get_full_name(), ".scoreboard_input_sig_coverage"});
    end
  endfunction

  // Absolute value function
  function real abs(real A);
    return (A < 0) ? -A : A;
  endfunction

  // Compare function (virtual for override in derived class)
  virtual function bit comp_equal(real input_freq, real actual_freq);
    real expected_freq = input_freq * 64; // Expected output frequency
    real error = expected_freq * freq_tol; // Tolerance window

    if (expected_freq == 0) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency ZERO in freq_generator: %f", expected_freq))
      in_dropped++;
      return 0;
    end

    if (abs(expected_freq - actual_freq) >= error) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency MISMATCH: expected=%f, actual=%f", expected_freq, actual_freq))
      num_mismatch++;
      return 0;
    end

    `uvm_info("PKT_COMPARE", $sformatf("Frequency MATCH: expected=%f, actual=%f", expected_freq, actual_freq), UVM_LOW)
    return 1;
  endfunction

  // Write function for registers
  virtual function void write_registers(registers_packet packet);
    `uvm_info("SCOREBOARD", $sformatf("Received packet: addr=%0h, wdata=%0h, wen=%0b, ren=%0b", packet.addr, packet.wdata, packet.wen, packet.ren), UVM_MEDIUM)
    reg_packets_in++;
    if (packet.addr > 7) begin
      reg_in_drop++;
      `uvm_warning("SCOREBOARD", $sformatf("Dropped packet: invalid addr=%0h", packet.addr))
      return;
    end
    if (packet.wen && !packet.ren) begin
      INT_REG[packet.addr] = packet.wdata;
      `uvm_info("SCOREBOARD", $sformatf("Stored in INT_REG[%0d]=%0h", packet.addr, packet.wdata), UVM_MEDIUM)
      if (packet.addr == 3) begin
        enable_pll = INT_REG[3][0];
        `uvm_info("SCOREBOARD", $sformatf("Updated enable_pll=%0b", enable_pll), UVM_MEDIUM)
      end
    end
  endfunction

  // Write function for frequency generator with added logging
  virtual function void write_osc_gen(osc_transaction packet);
    `uvm_info("SCOREBOARD", $sformatf("Received osc_gen packet: freq=%f", packet.freq), UVM_MEDIUM)
    freq_generator_packets_in++;
    freq = packet.freq;
    if (freq == -1) begin
      freq_generator_in_drop++;
      `uvm_warning("SCOREBOARD", $sformatf("Dropped osc_gen packet: invalid freq=%f", packet.freq))
      return;
    end
    freq_in_reg.push_back(freq); // Store input frequency
    `uvm_info("SCOREBOARD", $sformatf("Stored input frequency: freq=%f, queue_size=%0d", freq, freq_in_reg.size()), UVM_MEDIUM)
    if (coverage_control == COV_ENABLE) begin
      input_sig_cg.sample();
      `uvm_info("SCOREBOARD", $sformatf("Sampled coverage for freq=%f", freq), UVM_HIGH)
    end
  endfunction

  // Write function for frequency detector with added logging
  virtual function void write_osc_det(osc_transaction packet);
    `uvm_info("SCOREBOARD", $sformatf("Received osc_det packet: freq=%f", packet.freq), UVM_MEDIUM)
    freq_detector_packets_in++;
    if (!enable_pll) begin
      `uvm_info("SCOREBOARD", "PLL disabled (enable_pll=0), skipping comparison", UVM_MEDIUM)
      return;
    end

    freq_out = packet.freq;
    if (freq_out == -1) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency UNSTABLE at input freq=%f", freq_in_reg[0]))
      num_mismatch++;
      return;
    end

    if (freq_in_reg.size() == 0) begin
      `uvm_warning("PKT_COMPARE", "No input frequency available for comparison")
      return;
    end

    `uvm_info("SCOREBOARD", $sformatf("Comparing: input_freq=%f, output_freq=%f", freq_in_reg[0], freq_out), UVM_MEDIUM)
    match = comp_equal(freq_in_reg.pop_front(), freq_out);
    if (match) begin
      num_match++;
      `uvm_info("SCOREBOARD", "Frequency comparison passed", UVM_MEDIUM)
    end else begin
      `uvm_info("SCOREBOARD", "Frequency comparison failed", UVM_MEDIUM)
    end
    total_match_check++;
  endfunction

  // Report phase
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("SCOREBOARD REPORT:\n" +
                                        "\tPackets In: %0d\n" +
                                        "\tMatches: %0d\n" +
                                        "\tMismatches: %0d\n" +
                                        "\tDropped: %0d", 
                                        total_match_check, num_match, num_mismatch, in_dropped), UVM_LOW)
    if (num_mismatch > 0) begin
      `uvm_error(get_type_name(), "Simulation FAILED due to mismatches")
    end else begin
      `uvm_info(get_type_name(), "Simulation PASSED", UVM_NONE)
      if (coverage_control == COV_ENABLE) begin
        $display("** Overall Coverage = %f %% **", input_sig_cg.get_inst_coverage());
      end
    end
  endfunction
endclass

class pll_ms_scoreboard extends pll_scoreboard;
  `uvm_component_utils(pll_ms_scoreboard)

  // Additional variables for mixed-signal
  real ampl, bias; // Input amplitude and bias from freq_generator
  real ampl_out, bias_out; // Output amplitude and bias from freq_detector
  real ampl_tol = 0.05; // 5% tolerance for amplitude
  real bias_tol = 0.05; // 5% tolerance for bias

  // Variable for comparison result
  bit match;

  // Covergroup for mixed-signal parameters
  covergroup ms_sig_cg;
    option.per_instance = 1;
    freq_cov: coverpoint freq {
      bins DC         = { [0       : 9e5   ] };
      bins Hz         = { [9e5     : 10e3  ] };
      bins KHz        = { [10e3    : 10e6  ] };
      bins MHz        = { [10e6    : 10e7  ] };
      bins TenMHz     = { [10e7    : 10e8  ] };
      bins HundredMHz = { [10e8    : 10e9  ] };
      bins GHz        = { [10e9    : 10e10 ] };
      bins Max        = { [10e10   : $     ] };
    }
    ampl_cov: coverpoint ampl {
      bins Low  = { [0.0 : 0.5] };
      bins Mid  = { [0.5 : 1.0] };
      bins High = { [1.0 : 2.0] };
    }
    bias_cov: coverpoint bias {
      bins Neg  = { [-1.0 : -0.5] };
      bins Zero = { [-0.5 : 0.5] };
      bins Pos  = { [0.5 : 1.0] };
    }
  endgroup

  // Constructor
  function new(string name = "pll_ms_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    if (coverage_control == COV_ENABLE) begin
      ms_sig_cg = new();
      ms_sig_cg.set_inst_name({get_full_name(), ".scoreboard_ms_sig_coverage"});
    end
  endfunction

  // Override compare function to include amplitude and bias
  virtual function bit comp_equal(real input_freq, real actual_freq);
    real expected_freq = input_freq * 64;
    real freq_error = expected_freq * freq_tol;
    real ampl_error = ampl * ampl_tol;
    real bias_error = bias * bias_tol;
    bit freq_match, ampl_match, bias_match;

    // Frequency comparison
    if (expected_freq == 0) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency ZERO in freq_generator: %f", expected_freq))
      in_dropped++;
      return 0;
    end

    freq_match = (abs(expected_freq - actual_freq) < freq_error);
    ampl_match = (abs(ampl - ampl_out) < ampl_error);
    bias_match = (abs(bias - bias_out) < bias_error);

    if (!freq_match) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency MISMATCH: expected=%f, actual=%f", expected_freq, actual_freq))
      num_mismatch++;
    end
    if (!ampl_match) begin
      `uvm_error("PKT_COMPARE", $sformatf("Amplitude MISMATCH: expected=%f, actual=%f", ampl, ampl_out))
      num_mismatch++;
    end
    if (!bias_match) begin
      `uvm_error("PKT_COMPARE", $sformatf("Bias MISMATCH: expected=%f, actual=%f", bias, bias_out))
      num_mismatch++;
    end

    if (freq_match && ampl_match && bias_match) begin
      `uvm_info("PKT_COMPARE", $sformatf("MATCH: freq(expected=%f, actual=%f), ampl(expected=%f, actual=%f), bias(expected=%f, actual=%f)", 
                                         expected_freq, actual_freq, ampl, ampl_out, bias, bias_out), UVM_LOW)
      return 1;
    end
    return 0;
  endfunction

  // Override write_osc_gen for mixed-signal with added logging
  virtual function void write_osc_gen(osc_transaction packet);
    osc_ms_transaction sb_packet;
    if (!$cast(sb_packet, packet.clone())) begin
      `uvm_fatal("CAST_ERROR", "Failed to cast osc_transaction to osc_ms_transaction")
    end

    `uvm_info("SCOREBOARD", $sformatf("Received osc_gen packet: freq=%f, ampl=%f, bias=%f", sb_packet.freq, sb_packet.ampl, sb_packet.bias), UVM_MEDIUM)
    freq_generator_packets_in++;
    freq = sb_packet.freq;
    ampl = sb_packet.ampl;
    bias = sb_packet.bias;
    if (freq == -1) begin
      freq_generator_in_drop++;
      `uvm_warning("SCOREBOARD", $sformatf("Dropped osc_gen packet: invalid freq=%f", freq))
      return;
    end
    freq_in_reg.push_back(freq); // Store input frequency
    `uvm_info("SCOREBOARD", $sformatf("Stored input frequency: freq=%f, ampl=%f, bias=%f, queue_size=%0d", freq, ampl, bias, freq_in_reg.size()), UVM_MEDIUM)
    if (coverage_control == COV_ENABLE) begin
      ms_sig_cg.sample();
      `uvm_info("SCOREBOARD", $sformatf("Sampled coverage for freq=%f, ampl=%f, bias=%f", freq, ampl, bias), UVM_HIGH)
    end
  endfunction

  // Override write_osc_det for mixed-signal with added logging
  virtual function void write_osc_det(osc_transaction packet);
    osc_ms_transaction sb_packet;
    if (!$cast(sb_packet, packet.clone())) begin
      `uvm_fatal("CAST_ERROR", "Failed to cast osc_transaction to osc_ms_transaction")
    end

    `uvm_info("SCOREBOARD", $sformatf("Received osc_det packet: freq=%f, ampl=%f, bias=%f", sb_packet.freq, sb_packet.ampl, sb_packet.bias), UVM_MEDIUM)
    freq_detector_packets_in++;
    if (!enable_pll) begin
      `uvm_info("SCOREBOARD", "PLL disabled (enable_pll=0), skipping comparison", UVM_MEDIUM)
      return;
    end

    freq_out = sb_packet.freq;
    ampl_out = sb_packet.ampl;
    bias_out = sb_packet.bias;

    if (freq_out == -1) begin
      `uvm_error("PKT_COMPARE", $sformatf("Frequency UNSTABLE at input freq=%f", freq_in_reg[0]))
      num_mismatch++;
      return;
    end

    if (freq_in_reg.size() == 0) begin
      `uvm_warning("PKT_COMPARE", "No input frequency available for comparison")
      return;
    end

    `uvm_info("SCOREBOARD", $sformatf("Comparing: input_freq=%f, output_freq=%f, input_ampl=%f, output_ampl=%f, input_bias=%f, output_bias=%f", 
                                      freq_in_reg[0], freq_out, ampl, ampl_out, bias, bias_out), UVM_MEDIUM)
    match = comp_equal(freq_in_reg.pop_front(), freq_out);
    if (match) begin
      num_match++;
      `uvm_info("SCOREBOARD", "Mixed-signal comparison passed", UVM_MEDIUM)
    end else begin
      `uvm_info("SCOREBOARD", "Mixed-signal comparison failed", UVM_MEDIUM)
    end
    total_match_check++;
  endfunction

  // Report phase
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Mixed-Signal SCOREBOARD REPORT:\n" +
                                        "\tPackets In: %0d\n" +
                                        "\tMatches: %0d\n" +
                                        "\tMismatches: %0d\n" +
                                        "\tDropped: %0d", 
                                        total_match_check, num_match, num_mismatch, in_dropped), UVM_LOW)
    if (num_mismatch > 0) begin
      `uvm_error(get_type_name(), "Simulation FAILED due to mismatches")
    end else begin
      `uvm_info(get_type_name(), "Simulation PASSED", UVM_NONE)
      if (coverage_control == COV_ENABLE) begin
        $display("** Mixed-Signal Coverage = %f %% **", ms_sig_cg.get_inst_coverage());
      end
    end
  endfunction
endclass