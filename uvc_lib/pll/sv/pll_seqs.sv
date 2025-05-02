class base_seq extends uvm_sequence #(transaction);
  `uvm_object_utils(base_seq)

  function new(string name="base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body
endclass

class base_ms_seq extends uvm_sequence #(ms_transaction);
  `uvm_object_utils(base_ms_seq)

  function new(string name="base_ms_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass


// input threshold voltage
class input_threshold_seq extends base_seq;
  `uvm_object_utils(input_threshold_seq)
  int itr = 20;

  function new(string name = "input_threshold_seq");
    super.new(name);
  endfunction //new()

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("input_threshold_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Input Threshold Voltage test with %0d transactions", itr), UVM_LOW)

    // drive signals
    for(int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; ampl inside {[0.8:1.2]}; bias inside {[-0.3:0.3]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_LOW)
      `uvm_send(req)
    end

    // sample signal to measure
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 30; delay == 0.5;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)


  endtask //body
endclass //input_threshold_seq extends base_seq

// Sequence cho PLL Lock Time
class lock_time_seq extends base_ms_seq;
  `uvm_object_utils(lock_time_seq)

  function new(string name="lock_time_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Running PLL Lock Time test...", UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[25e6:30e6]};});
    `uvm_info(get_type_name(), $sformatf("Sending drive transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)

    // Lấy mẫu (SAMPLE) để đo lock_time
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 25; delay == 0.2;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Output Threshold Voltage
class output_threshold_seq extends base_ms_seq;
  `uvm_object_utils(output_threshold_seq)

  int itr = 20;

  function new(string name="output_threshold_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("output_threshold_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Output Threshold Voltage test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; ampl inside {[1.5:2.0]}; bias inside {[-0.3:0.3]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo lường
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 30; delay == 0.5;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Phase Noise
class phase_noise_seq extends base_ms_seq;
  `uvm_object_utils(phase_noise_seq)

  int itr = 20;

  function new(string name="phase_noise_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("phase_noise_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Phase Noise test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[28e6:32e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo phase_error
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 32; delay == 0.1;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Jitter
class jitter_seq extends base_ms_seq;
  `uvm_object_utils(jitter_seq)

  int itr = 20;

  function new(string name="jitter_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("jitter_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Jitter test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[25e6:30e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo jitter_rms
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 30; delay == 0.3;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Frequency Stability
class freq_stability_seq extends base_ms_seq;
  `uvm_object_utils(freq_stability_seq)

  int itr = 20;

  function new(string name="freq_stability_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("freq_stability_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Frequency Stability test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[26e6:33e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo measured_freq
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 28; delay == 0.2;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Loop Bandwidth
class loop_bandwidth_seq extends base_ms_seq;
  `uvm_object_utils(loop_bandwidth_seq)

  int itr = 20;

  function new(string name="loop_bandwidth_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("loop_bandwidth_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Loop Bandwidth test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE) với tần số thay đổi để đo băng thông
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[25e6:34e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo phản hồi
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 25; delay == 0.4;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Spurious Signals
class spurious_signals_seq extends base_ms_seq;
  `uvm_object_utils(spurious_signals_seq)

  int itr = 20;

  function new(string name="spurious_signals_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("spurious_signals_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Spurious Signals test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; freq inside {[27e6:31e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo measured_freq và phát hiện tần số không mong muốn
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 32; delay == 0.1;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass

// Sequence cho Power Supply Sensitivity
class power_supply_sensitivity_seq extends base_ms_seq;
  `uvm_object_utils(power_supply_sensitivity_seq)

  int itr = 20;

  function new(string name="power_supply_sensitivity_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("power_supply_sensitivity_seq.itr", itr));
    `uvm_info(get_type_name(), $sformatf("Running Power Supply Sensitivity test with %0d transactions", itr), UVM_HIGH)

    // Gửi tín hiệu điều khiển (DRIVE) với bias thay đổi để mô phỏng nhiễu nguồn
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {data_type == PLL_MS_DRIVE; enable == 1; bias inside {[-1.0:1.0]}; freq inside {[25e6:30e6]};});
      `uvm_info(get_type_name(), $sformatf("Sending transaction %0d: %s", i, req.convert2string()), UVM_MEDIUM)
      `uvm_send(req)
    end

    // Lấy mẫu (SAMPLE) để đo ảnh hưởng
    `uvm_create(req)
    void'(req.randomize() with {data_type == PLL_MS_SAMPLE; enable == 1; duration == 30; delay == 0.5;});
    `uvm_info(get_type_name(), $sformatf("Sending sample transaction: %s", req.convert2string()), UVM_MEDIUM)
    `uvm_send(req)
  endtask
endclass




class nested_seq extends base_seq;
  `uvm_object_utils(nested_seq)

  function new(string name="nested_seq");
    super.new(name);
  endfunction

  task body();
    int itr = 20;
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("nested_seq.itr", itr));
    `uvm_info(get_type_name(),
       $sformatf("Running... (%0d transaction sequences)", itr), UVM_HIGH)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize());
      `uvm_send(req)
    end
  endtask

endclass

class ms_source_transaction_seq extends base_ms_seq;
  `uvm_object_utils(ms_source_transaction_seq)

  function new(string name="ms_source_transaction_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Running...", UVM_HIGH)
    `uvm_do_with(req, {data_type == data_type; enable == enable;})
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass

class ms_source_nested_seq extends base_ms_seq;
  `uvm_object_utils(ms_source_nested_seq)

  function new(string name="ms_source_nested_seq");
    super.new(name);
  endfunction

  task body();
    int itr = 20;
    uvm_component parent = get_sequencer();
    void'(parent.get_config_int("ms_source_nested_seq.itr", itr));
    `uvm_info(get_type_name(),
       $sformatf("Running... (%0d ms_source_transaction sequences)", itr), UVM_HIGH)
    for (int i = 0; i < itr; i++) begin
      `uvm_create(req)
      void'(req.randomize() with {req.data_type == PLL_MS_DRIVE; req.enable == 1;});
      `uvm_send(req)
    end
  endtask

  task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  task post_body();
    uvm_test_done.drop_objection(this);
  endtask
endclass



