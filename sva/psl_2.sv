`include "constants.vams"
`include "disciplines.vams"

// Macro để phát hiện chu kỳ và tính tần số
`define DETECT_FREQ(Node, threshold, period, freq, enable) \
    real last_crossing; \
    real current_crossing; \
    logic crossing_detected; \
    real period_measured; \
    real freq_measured; \
    initial begin \
        last_crossing = 0.0; \
        crossing_detected = 0; \
        period_measured = 0.0; \
        freq_measured = 0.0; \
    end \
    always @(V(Node)) begin \
        if (enable && V(Node) > threshold && !crossing_detected) begin \
            current_crossing = $realtime; \
            if (last_crossing != 0.0) begin \
                period_measured = (current_crossing - last_crossing) * 1e-9; \
                freq_measured = 1.0 / period_measured; \
            end \
            last_crossing = current_crossing; \
            crossing_detected = 1; \
        end \
        if (V(Node) < threshold) begin \
            crossing_detected = 0; \
        end \
    end \
    assign period = period_measured; \
    assign freq = freq_measured;

// Vunit gắn vào mô-đun PLL
vunit pll_vunit(pll) (
    electrical fref, fout, fdiv;
);

// Khởi tạo tín hiệu enable
logic enable = 1;

// Đo tần số của fref
real fref_period, fref_freq;
`DETECT_FREQ(fref, 0.5, fref_period, fref_freq, enable)

// Đo tần số của fout
real fout_period, fout_freq;
`DETECT_FREQ(fout, 0.5, fout_period, fout_freq, enable)

// Đo tần số của fdiv
real fdiv_period, fdiv_freq;
`DETECT_FREQ(fdiv, 0.5, fdiv_period, fdiv_freq, enable)

// Khẳng định PSL
// 1. Kiểm tra tần số của fref (30 MHz ± 5% = [28.5 MHz, 31.5 MHz])
psl assert always (fref_freq >= 28.5e6 && fref_freq <= 31.5e6) after 10us
    report "F_REF frequency is not within 30 MHz ±5% after 10us";

// 2. Kiểm tra tần số của fout (1.9 GHz ± 5% = [1.805 GHz, 1.995 GHz])
psl assert always (fout_freq >= 1.805e9 && fout_freq <= 1.995e9) after 10us
    report "F_OUT frequency is not within 1.9 GHz ±5% after 10us";

// 3. Kiểm tra tần số của fdiv khớp với fref
psl assert always (fdiv_freq >= 28.5e6 && fdiv_freq <= 31.5e6) after 10us
    report "F_DIV frequency does not match F_REF after 10us";

endmodule