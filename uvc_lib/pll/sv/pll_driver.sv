class pll_driver extends uvm_driver #(pll_transaction);

  virtual interface pll_if vif;

  int num_sent;
  real period;

  `uvm_component_utils_begin(pll_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
    `uvm_field_real(period, UVM_ALL_ON)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual pll_if)::get(this, "", "vif", vif))
      `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    get_and_drive();
  endtask : run_phase

  virtual task get_and_drive();
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), $sformatf("Sending Packet:\n%s", req.sprint()), UVM_HIGH)
      void'(begin_tr(req, "PLL Driver"));
      fork
        vif.send_to_dut(req.freq);
        begin
          vif.sig_en = 1;
          #(1ps) vif.sig_en = 0;
          #(1ps) vif.sig_en = 1;
        end
        begin: clk_gen
          @(posedge vif.sig_en)
          period = 1 / req.freq;
          clock_in_gen(period);
        end
        begin
          @(posedge vif.sig_en);
          #(200 * 1ns) disable clk_gen;
          vif.clk = 0;
        end
      join
      end_tr(req);
      seq_item_port.item_done();
      num_sent++;
    end
  endtask : get_and_drive

  task clock_in_gen(input real period);
    vif.clk = 0;
    forever begin
      #(period * 50 * 0.01 * 1s)
      vif.clk = !vif.clk;
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("\nReport: PLL driver sent %0d packets in total.", num_sent), UVM_LOW)
  endfunction

endclass : pll_driver

class pll_ms_source_driver extends pll_driver;

  protected pll_bridge_proxy bridge_proxy;
  pll_ms_transaction ms_req;
  int num_sent;

  `uvm_component_utils_begin(pll_ms_source_driver)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(pll_bridge_proxy)::get(this, "", "bridge_proxy", bridge_proxy))
      `uvm_error(get_type_name(), "bridge proxy not configured");
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      get_and_drive();
    join
  endtask

  task get_and_drive();
    forever begin
      seq_item_port.get_next_item(req);
      $cast(ms_req, req);
      drive_transaction(ms_req);
      fork
        #(200 * 1ns);
        begin : sample_thread
          #(1ns) bridge_proxy.sampling_do = 1;
          #(1ns) bridge_proxy.sampling_do = 0;
        end
      join
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  task drive_transaction(pll_ms_transaction transaction);
    `uvm_info(get_type_name(), $psprintf("Item %0d To Send:\n%s", num_sent, transaction.sprint()), UVM_HIGH)
    if (transaction.data_type == PLL_MS_DRIVE) begin
      bridge_proxy.config_wave(.ampl(transaction.ampl), .bias(transaction.bias), .freq(transaction.freq),
        .enable(transaction.enable));
      bridge_proxy.delay_in = transaction.delay;
      bridge_proxy.duration_in = transaction.duration;
      num_sent++;
      `uvm_info(get_type_name(), $psprintf("Item %0d Sent", num_sent), UVM_MEDIUM)
    end else begin
      `uvm_info(get_type_name(), "Only Drive transactions are supported", UVM_LOW)
    end
  endtask : drive_transaction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("\nReport: PLL_MS driver sent %0d transactions", num_sent), UVM_LOW)
  endfunction

endclass : pll_ms_source_driver