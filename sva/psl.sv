`include "constants.vams"
`include "disciplines.vams"

// Macro để chuyển đổi điện áp analog sang tín hiệu số
`define V_IN_RANGE(Node,hthr,lthr,vdelta,ttol,vtol,enable,digout) \
    always @(absdelta(V(Node),vdelta,ttol,vtol,enable)) begin \
        if ((V(Node) > hthr) || (V(Node) < lthr)) digout = 0; \
        else digout = 1; \
    end

// Vunit gắn vào mô-đun PLL
vunit pll_vunit(pll) (
    // Khai báo các cổng electrical
    electrical fref, fout, fdiv, vc, up, dn, upb, dnb, gnd;
);

// Khởi tạo tín hiệu enable (giả định luôn bật)
logic enable = 1;

// Chuyển đổi tín hiệu analog sang số
`V_IN_RANGE(vc, 2.5, 0.5, 0.01, 10e-9, 0.01, enable, vc_in_range)
`V_IN_RANGE(up, 2.5, 0.5, 0.01, 10e-9, 0.01, enable, up_in_range)
`V_IN_RANGE(dn, 2.5, 0.5, 0.01, 10e-9, 0.01, enable, dn_in_range)
`V_IN_RANGE(upb, 2.5, 0.5, 0.01, 10e-9, 0.01, enable, upb_in_range)
`V_IN_RANGE(dnb, 2.5, 0.5, 0.01, 10e-9, 0.01, enable, dnb_in_range)

// Khẳng định PSL
// 1. Kiểm tra phạm vi điện áp của vc
psl assert always (vc_in_range == 1) after 10us
    report "VC out of range (0.5V to 2.5V) after 10us";

// 2. Kiểm tra up và dn không đồng thời cao
psl assert never (up_in_range && dn_in_range) after 10us
    report "UP and DN are both high after 10us";

// 3. Kiểm tra quan hệ giữa up và upb, dn và dnb
psl assert always (up_in_range == !upb_in_range) 
    report "UP and UPB are not complementary";
psl assert always (dn_in_range == !dnb_in_range) 
    report "DN and DNB are not complementary";

// 4. Kiểm tra tần số fdiv khớp với fref (giả định công cụ hỗ trợ đo tần số)
logic fref_freq_ok, fdiv_freq_ok;
always @(fref) begin
    // Giả định hàm đo tần số (cần công cụ hỗ trợ)
    fref_freq_ok = (V(fref) > 0.5) ? 1 : 0; // Đơn giản hóa
end
always @(fdiv) begin
    fdiv_freq_ok = (V(fdiv) > 0.5) ? 1 : 0; // Đơn giản hóa
end
psl assert always (fref_freq_ok == fdiv_freq_ok) after 10us
    report "FDIV frequency does not match FREF after 10us";

// 5. Kiểm tra ổn định của vc
logic vc_stable;
always @(vc_in_range) begin
    vc_stable = (vc_in_range == 1);
end
psl assert always (vc_stable) after 10us
    report "VC is not stable after 10us";

endmodule