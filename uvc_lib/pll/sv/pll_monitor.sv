class pll_monitor extends uvm_monitor;

  virtual interface pll_if vif;
  int num_col;
  real last_freq;
  real period;
  real tupd;

  pll_transaction pll_fout_transaction;

  uvm_analysis_port #(pll_transaction) item_collected_port;

  `uvm_component_utils_begin(pll_monitor)
    `uvm_field_int(num_col, UVM_ALL_ON)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual pll_if)::get(this, get_full_name(), "vif", vif))
      `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    collect_DUT_output();
  endtask : run_phase

  virtual task collect_DUT_output();
    forever begin
      fork
        begin: meas_pll_fout_freq
          @(posedge vif.sig_en);
          pll_fout_transaction = pll_transaction::type_id::create("pll_fout_transaction", this);
          void'(begin_tr(pll_fout_transaction, "PLL_Monitor"));
          forever begin
            @(posedge vif.fout);
            last_freq = pll_fout_transaction.freq;
            period = $realtime - tupd;
            pll_fout_transaction.freq = (1s / period);
            tupd = $realtime;
            item_collected_port.write(pll_fout_transaction);
            end_tr(pll_fout_transaction);
          end
        end
        begin
          @(negedge vif.sig_en)
          disable meas_pll_fout_freq;
          num_col++;
          `uvm_info(get_type_name(), $sformatf("Report: Monitor Collected %0d pll_fout_transactions", num_col), UVM_FULL)
          last_freq = 0;
        end
      join
    end
  endtask : collect_DUT_output

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("\nReport: pll_monitor collected frequency %0d times in total.", num_col),
      UVM_LOW)
  endfunction

endclass : pll_monitor

class pll_ms_source_monitor extends pll_monitor;

  protected pll_bridge_proxy bridge_proxy;
  int num_col;

  bit checks_enable = 1;
  bit coverage_enable = 1;

  protected pll_ms_transaction transaction;

  bit [63:0] freq_vec;
  bit [63:0] lock_time_vec;
  bit [63:0] jitter_vec;

  covergroup pll_metrics_cg;
    option.per_instance = 1;
    frequency : coverpoint freq_vec {
      bins MHz = {[64'h416312D000000000:64'h4197D78400000000]};
      bins GHz = {[64'h4202A05F20000000:64'h42374876E8000000]};
    }
    lock_time : coverpoint lock_time_vec {
      bins fast = {[0:64'h408f400000000000]}; // < 1us
      bins slow = {[64'h408f400000000000:$]}; // > 1us
    }
    jitter : coverpoint jitter_vec {
      bins low = {[0:64'h4024000000000000]}; // < 10ps
      bins high = {[64'h4024000000000000:$]}; // > 10ps
    }
  endgroup : pll_metrics_cg

  `uvm_component_utils_begin(pll_ms_source_monitor)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
    void'(get_config_int("coverage_enable", coverage_enable));
    if (coverage_enable) begin
      pll_metrics_cg = new();
      pll_metrics_cg.set_inst_name("pll_metrics_cg");
    end
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(pll_bridge_proxy)::get(this, "", "bridge_proxy", bridge_proxy))
      `uvm_error(get_type_name(), "bridge proxy not configured");
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    run();
  endtask : run_phase

  task run();
    fork
      collect_transaction();
    join_none
  endtask : run

  task collect_transaction();
    transaction = pll_ms_transaction::type_id::create("transaction", this);
    forever begin
      @(posedge bridge_proxy.sampling_done);
      void'(begin_tr(transaction, "PLL MS Monitor"));
      transaction.data_type = PLL_MS_SAMPLE;
      transaction.measured_freq = bridge_proxy.freq_out;
      transaction.lock_time = bridge_proxy.lock_time_out;
      transaction.jitter_rms = bridge_proxy.jitter_rms_out;
      `uvm_info(get_type_name(),
        $psprintf("Transaction collected:\n%s", transaction.sprint()), UVM_LOW)
      if (checks_enable)
        perform_checks();
      if (coverage_enable)
        perform_coverage();
      item_collected_port.write(transaction);
      num_col++;
      fork
        begin : wait_for_sampling_done
          @(negedge bridge_proxy.sampling_done);
          disable wait_for_timeout;
        end
        begin : wait_for_timeout
          #150ns;
          disable wait_for_sampling_done;
        end
      join
      end_tr(transaction);
    end
  endtask : collect_transaction

  function void perform_checks();
    // Kiểm tra Lock Frequency Range
    if (transaction.measured_freq < 1.6e9 || transaction.measured_freq > 2.2e9)
      `uvm_error("CHECK_FAIL", $sformatf("Frequency out of range: %0f Hz", transaction.measured_freq))
    // Kiểm tra Lock Time
    if (transaction.lock_time > 1e3) // > 1us
      `uvm_warning("CHECK_WARN", $sformatf("Lock time too high: %0f ns", transaction.lock_time))
    // Kiểm tra Jitter
    if (transaction.jitter_rms > 10) // > 10ps
      `uvm_warning("CHECK_WARN", $sformatf("Jitter RMS too high: %0f ps", transaction.jitter_rms))
  endfunction : perform_checks

  function void perform_coverage();
    freq_vec = $realtobits(transaction.measured_freq);
    lock_time_vec = $realtobits(transaction.lock_time);
    jitter_vec = $realtobits(transaction.jitter_rms);
    `uvm_info(get_type_name(), "Gathering PLL metrics coverage", UVM_MEDIUM)
    pll_metrics_cg.sample();
  endfunction : perform_coverage

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("\nReport: PLL MS monitor collected %0d transactions", num_col),
      UVM_LOW)
  endfunction

endclass : pll_ms_source_monitor