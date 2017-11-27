`include "def.sv"
`include "CPU.sv"
`include "sign_extend.sv"
`include "mux2to1.sv"
`include "mux4to1.sv"
`include "alu_control.sv"
`include "control.sv"
`include "reg_32x32.sv"
`include "ALU.sv"

module top(
  input clk,
  input rst,
  input  stall,
  input [31:0] IM_out,
  input [31:0] DM_out,
  output IM_enable,
  output [31:0] IM_address,
  output DM_write,
  output DM_enable,
  output [31:0] DM_in,
  output [31:0] DM_address
);

  CPU CPU1 (
      .clk(clk),
      .rst(rst),
      .stall(stall),
    .IM_address(IM_address),
    .IM_enable(IM_enable),
    .IM_out(IM_out),

    .DM_address(DM_address),
    .DM_in(DM_in),
    .DM_enable(DM_enable),
    .DM_write(DM_write),
    .DM_out(DM_out)
  );

endmodule
