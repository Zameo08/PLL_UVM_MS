vunit pll_io_check(pll) {
    // param
    const real N = 64;              // Tỷ lệ chia tần số
    const real clk_threshold = 0.5; // Ngưỡng tín hiệu
    const real Vamp = 1;            // Biên độ fout
    const real vtol = 0.01;         // Dung sai điện áp
    const real lock_time = 1u;      // Thời gian khóa tối đa (1us)
    const real Fmin = 1.6e9;        // Tần số tối thiểu của fout
    const real Fmax = 2.2e9;        // Tần số tối đa của fout

    // Assertion 1: when locked fout = N * fref
    property pll_freq_lock;
        @(cross(V(fref) - clk_threshold, +1))
        eventually {
            // count rising edge of fout in a period
            integer count = 0;
            real start_time = $realtime;
            @(cross(V(fout) - clk_threshold, +1)) count = count + 1;
        } within lock_time;
    endproperty
    assert pll_freq_lock report "PLL: fout frequency not equal to N * fref";

    // Assertion 2: amplifier of fout
    property pll_fout_amplitude;
        @(cross(V(fout) - clk_threshold, +1))
        abs(V(fout) - Vamp) < vtol || abs(V(fout)) < vtol;
    endproperty
    assert pll_fout_amplitude report "PLL: Incorrect fout amplitude";

    // Assertion 3: fout in range [Fmin, Fmax]
    property pll_fout_freq_range;
        @(cross(V(fout) - clk_threshold, +1))
        always {
            real period = $realtime - $past($realtime, 1);
            real freq = 1.0 / period;
            freq >= Fmin && freq <= Fmax;
        }
    endproperty
    assert pll_fout_freq_range report "PLL: fout frequency out of range";

    // Assertion 4: lock_time
    property pll_lock_time;
        @(initial_step)
        eventually {
            @(cross(V(fref) - clk_threshold, +1))
            cross(V(fout) - clk_threshold, +1)[*N/2] within 1n;
        } within lock_time;
    endproperty
    assert pll_lock_time report "PLL: Lock time exceeded";
}