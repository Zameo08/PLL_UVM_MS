// Check Fref period in 30MHz ± 0.1MHz → period ≈ 33.333ns ± ~0.1ns
property fref_freq_check;
    @(posedge Fref)
        $rose(Fref) |=> ##1 $fell(Fref) ##1 $rose(Fref)
        ##0 ($time - $past($rose(Fref))) inside {[33.2ns:33.5ns]};
endproperty
assert property (fref_freq_check)
    else $error("Fref is out of expected 30 MHz range!");

// Period = ~0.526ns ± ~0.014ns
property fout_freq_check;
    @(posedge Fout)
        $rose(Fout) |=> ##1 $fell(Fout) ##1 $rose(Fout)
        ##0 ($time - $past($rose(Fout))) inside {[0.512ns:0.540ns]};
endproperty

assert property (fout_freq_check)
    else $error("Fout is out of expected 1.9 GHz range!");

logic locked; // Assume PLL has a locked signal

property fout_after_lock;
    @(posedge clk) // clk là clock testbench hoặc Fref
    $rose(locked) |=> ##[1:$] $rose(Fout);
endproperty

assert property (fout_after_lock)
    else $error("Fout does not appear after PLL locked!");

real vin;  // dùng từ analog domain đưa qua veriloga2sv

    // Kiểm tra nếu vin vượt 3.3V hoặc thấp hơn 0V thì báo lỗi
property voltage_range_check;
    @(posedge clk)
    disable iff (reset)
    !(vin > 3.3 || vin < 0);
endproperty
    
assert property (voltage_range_check)
    else $fatal("Vin out of safe operating range!");

    
real fout_voltage;

property fout_voltage_level;
    @(posedge clk)
    fout_voltage >= 0.5 && fout_voltage <= 5.5;
endproperty

assert property (fout_voltage_level)
    else $error("Fout voltage out of logic level range!");

    
real vdd;

property vdd_safe_range;
    @(posedge clk)
    vdd inside {[4.5:5.5]};
endproperty

assert property (vdd_safe_range)
    else $fatal("VDD out of safe operating range!");
