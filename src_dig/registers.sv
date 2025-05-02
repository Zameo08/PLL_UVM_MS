// register.sv - Register block for PLL
`timescale 1ns/1ps

module registers (
  input       clk,
  input       rst_n,
  input [7:0] addr,
  input [7:0] wdata,
  input       wen,
  input       ren,
  output reg [7:0] rdata,

  output wire [7:0] div_cfg,
  output wire [3:0] vco_gain,
  output wire [1:0] lpf_rp,
  output wire [1:0] lpf_cp,
  output wire [1:0] lpf_c2,
  output wire       enable_pll
);


  // Register memory (4 registers)
  logic [7:0] INT_REG [3:0];

  // Read/Write logic
  always_ff @(posedge clk or  negedge rst_n) begin
    if (!rst_n) begin
      INT_REG[0] <= 8'd0;
      INT_REG[1] <= 8'd0;
      INT_REG[2] <= 8'd0;
      INT_REG[3] <= 8'd0;
      rdata      <= 8'd0;
    end
    else if (wen && !ren) begin
      rdata <= 8'h00;
      if (addr < 4)
        INT_REG[addr] <= wdata;
    end 
    else if (!wen && ren) begin
      if (addr < 4)
        rdata <= INT_REG[addr];
      else
        rdata <= 8'h00;
    end 
    else if (wen && ren) begin
      rdata <= 8'hxx; // undefined
    end 
    else begin
      rdata <= 8'h00;
    end
  end

  // Assign outputs from register bits
  assign div_cfg     = INT_REG[0];
  assign vco_gain    = INT_REG[1][3:0];
  assign lpf_c2      = INT_REG[2][5:4];
  assign lpf_cp      = INT_REG[2][3:2];
  assign lpf_rp      = INT_REG[2][1:0];
  assign enable_pll  = INT_REG[3][0];

endmodule
