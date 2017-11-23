
module control 
  (
    output logic [1:0] ALU_op,
    output logic [1:0] DMtoReg,
    output logic RegWrite, DM_en, DM_write, jump, branch, ALU_src,
    output logic auipc,
    input [6:0] op 
  );
  // ALU OP
	parameter rty_ = 2'b00;
	parameter ity_ = 2'b01;		// add imm
	parameter lsb_ = 2'b10;		// lw, s type, b type
  parameter els_ = 2'b11;		// else
  // ALU src
  parameter reg_ = 1'b0;
	parameter imm_ = 1'b1;
  // DM to Reg
  parameter im__ = 2'b00;
  parameter pc4_ = 2'b01;
  parameter alu_ = 2'b10;
  parameter dm__ = 2'b11;
  // else
	parameter tru_ = 1'b1;
	parameter fal_ = 1'b0;

  always_comb
  begin
    case (op)
      `R_type:
      begin
        ALU_op   = rty_;  // r type
        DMtoReg  = alu_;	// alu to reg
        RegWrite = tru_;	// write reg
        DM_en    = fal_;	// no DM
        DM_write = fal_;	// no DM
        jump     = fal_;	// no J
        branch   = fal_;	// no B
        ALU_src  = reg_;	// reg
        auipc    = fal_;  // auipc sel
      end
      `I_type:
      begin
        ALU_op   = ity_;  // i type
        DMtoReg  = alu_;  // alu to DM
        RegWrite = tru_;  // write reg
        DM_en    = fal_;  // no DM
        DM_write = fal_;  // no DM
        jump     = fal_;  // no J
        branch   = fal_;  // no B
        ALU_src  = imm_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `OP_LW:
      begin
        ALU_op   = lsb_;  // LW
        DMtoReg  = dm__;  // DM  to reg
        RegWrite = tru_;  // write reg
        DM_en    = tru_;  // DM
        DM_write = fal_;  // no write DM
        jump     = fal_;  // no J
        branch   = fal_;  // no B
        ALU_src  = imm_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `OP_JALR:
      begin
        ALU_op   = ity_;
        DMtoReg  = pc4_;  // DM  to reg
        RegWrite = tru_;  // write reg
        DM_en    = tru_;  // DM
        DM_write = fal_;  // no write DM
        jump     = tru_;  // J type
        branch   = fal_;  // no B
        ALU_src  = imm_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `S_type:
      begin
        ALU_op   = lsb_;  // SW
        DMtoReg  = im__;  // no reg
        RegWrite = fal_;  // write reg
        DM_en    = tru_;  // DM
        DM_write = tru_;  // no write DM
        jump     = fal_;  // no J
        branch   = fal_;  // no B
        ALU_src  = imm_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `B_type:
      begin
        ALU_op   = lsb_;	// b type
        DMtoReg  = im__;  // no reg
        RegWrite = fal_;  // no write reg
        DM_en    = fal_;  // DM
        DM_write = fal_;  // no write DM
        jump     = fal_;  // no J
        branch   = tru_;  // B
        ALU_src  = fal_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `U_type:
      begin
        ALU_op   = els_;	// else
        DMtoReg  = im__;	// imm to reg
        RegWrite = tru_;	// write reg
        DM_en    = fal_;	// no DM
        DM_write = fal_;	// no write DM
        jump     = fal_;	// no J
        branch   = fal_;	// no B
        ALU_src  = imm_;  // imm
        auipc    = fal_;  // auipc sel
      end
      `OP_AUPC:
      begin
        ALU_op   = els_;	// else
        DMtoReg  = alu_;	// alu to reg
        RegWrite = tru_;	// write reg
        DM_en    = fal_;	// no DM
        DM_write = fal_;	// no write DM
        jump     = fal_;	// no J
        branch   = fal_;	// no B
        ALU_src  = imm_;  // imm
        auipc    = tru_;  // auipc sel
      end
      `J_type:
      begin
        ALU_op   = els_;	// b type
        DMtoReg  = pc4_;	// pc4 to reg
        RegWrite = tru_;	// write reg
        DM_en    = fal_;	// no DM
        DM_write = fal_;	// no write DM
        jump     = tru_;	// J
        branch   = fal_;	// no B
        ALU_src  = imm_;	// imm
        auipc    = fal_;  // auipc sel
      end
      default:
      begin
        ALU_op   = els_;
        DMtoReg  = im__;
        RegWrite = fal_;
        DM_en    = fal_;
        DM_write = fal_;
        jump     = fal_;
        branch   = fal_;
        ALU_src  = imm_;
        auipc    = fal_;  // auipc sel
      end
    endcase
  end
  
endmodule
