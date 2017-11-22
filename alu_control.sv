`include "def.sv"

module alu_control 
  ( 
    output logic [`ALU_si-1:0] alu_func,
    input [1:0] ALU_op,
    input [2:0] func3,
    input [6:0] func7
  );
  parameter rty_ = 2'b00;
  parameter ity_ = 2'b01;		// add imm
  parameter lsb_ = 2'b10;		// b type
  parameter els_ = 2'b11;		// else

  wire sub = (func7 == 7'b0100000)? 1:0;
  always_comb begin  
    case (ALU_op)
      rty_:    alu_func = { sub, func3 };
      ity_:    alu_func = { 1'b0, func3 };
      //lsb_:    alu_func = (func3 == 3'b010)? 4'd0 : (func3 == 3'b001)? 4'd10 : 4'd9;
      lsb_:    alu_func = (func3 == 3'b010)? 4'd0 : 4'd9;
      els_:    alu_func = 4'd0;
      default: alu_func = 4'd0;
    endcase 
  end  
  
endmodule
