module sign_extend 
  (
    output logic [31:0] se_imm,
    input [11:0] I_imm,
    input [11:0] S_imm,
    input [11:0] B_imm,
    input [19:0] U_imm,
    input [19:0] J_imm,
    input [6:0] op
  );

  always_comb
  begin
    case (op)
      `I_type:
      begin
        se_imm = (I_imm[11] == 1)? { 20'hfffff, I_imm } : { 20'h00000, I_imm };
      end 
      `S_type:
      begin
        se_imm = (S_imm[11] == 1)? { 20'hfffff, S_imm } : { 20'h00000, S_imm };
      end
      `B_type:
        se_imm = (B_imm[11] == 1)? { 16'hffff, 3'b111, B_imm, 1'b0 } : { 19'b0, B_imm, 1'b0 };
      `U_type:
        se_imm = {U_imm, 12'b0 };
        //se_imm = (U_imm[19] == 1)? { 12'hfff, U_imm } : { 12'b0, U_imm };
      `OP_AUPC:
        se_imm = {U_imm, 12'b0 };
      `J_type:
        se_imm = (J_imm[19] == 1)? { 8'hff, 3'b111, J_imm, 1'b0 } : { 11'b0, J_imm, 1'b0 };
      `OP_LW:
        se_imm = (I_imm[11] == 1)? { 20'hfffff, I_imm } : { 20'h00000, I_imm };
      `OP_JALR:
        se_imm = (I_imm[11] == 1)? { 20'hfffff, I_imm } : { 20'h00000, I_imm };
      default:
        se_imm = 32'b0;
    endcase
  end
  
endmodule
