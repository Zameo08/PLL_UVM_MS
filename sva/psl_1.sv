`include "constants.vams"
`include "disciplines.vams"

vunit pll_assertions(pll) {
    // Định nghĩa đồng hồ mặc định dựa trên cạnh dương của fref
    default clock = (cross(V(fref), +1));

    // Biến phụ trợ để đơn giản hóa xác nhận
    real abs_vc, abs_fout, abs_fdiv;
    integer fref_positive, fdiv_positive;
    integer up_active, dn_active;
    analog begin
        abs_vc = abs(V(vc));
        abs_fout = abs(V(fout));
        abs_fdiv = abs(V(fdiv));
        fref_positive = V(fref) > 0.0;
        fdiv_positive = V(fdiv) > 0.0;
        up_active = V(up) > 0.5; // Giả định tín hiệu logic cao > 0.5V
        dn_active = V(dn) > 0.5;
    end

    // 1. Xác nhận PFD: Nếu fref dẫn trước fdiv về pha, up được kích hoạt
    pfd_up_behavior: assert always ({fref_positive && !fdiv_positive} |=> up_active);

    // 2. Xác nhận PFD: Nếu fdiv dẫn trước fref về pha, dn được kích hoạt
    pfd_dn_behavior: assert always ({fdiv_positive && !fref_positive} |=> dn_active);

    // 3. Xác nhận PFD: up và dn không được kích hoạt cùng lúc
    pfd_no_simultaneous: assert never (up_active && dn_active);

    // 4. Xác nhận CP: Nếu up được kích hoạt, vc tăng trong chu kỳ tiếp theo
    cp_up_increase: assert always (up_active |=> V(vc) > prev(V(vc)));

    // 5. Xác nhận CP: Nếu dn được kích hoạt, vc giảm trong chu kỳ tiếp theo
    cp_dn_decrease: assert always (dn_active |=> V(vc) < prev(V(vc)));

    // 6. Xác nhận CP: Nếu không có up hoặc dn, vc giữ ổn định
    cp_stable: assert always (!(up_active || dn_active) |=> V(vc) == prev(V(vc)));

    // 7. Xác nhận VCO: Tần số fout tăng khi vc tăng (giả định tuyến tính đơn giản)
    vco_frequency: assert always (V(vc) > prev(V(vc)) |=> abs_fout > prev(abs_fout));

    // 8. Xác nhận Frequency Divider: fdiv có tần số thấp hơn fout
    divider_behavior: assert always (abs_fdiv <= abs_fout);

    // 9. Xác nhận ổn định PLL: Khi khóa pha, fref và fdiv có pha tương đương
    pll_locked_phase: assert eventually always (fref_positive <-> fdiv_positive);

    // 10. Xác nhận giới hạn: vc nằm trong khoảng an toàn (giả định 0V đến 5V)
    vc_bound: assert always (abs_vc >= 0.0 && abs_vc <= 5.0);

    // 11. Xác nhận giới hạn: fout nằm trong khoảng tần số hợp lệ (giả định biên độ tối đa 5V)
    fout_bound: assert always (abs_fout <= 5.0);

    // 12. Xác nhận không có dao động bất thường: Không có chuỗi dài các up hoặc dn liên tục
    no_long_up_seq: assert never {up_active[*10]};
    no_long_dn_seq: assert never {dn_active[*10]};
}