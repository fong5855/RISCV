`ifndef DEFSV
`define DEFSV 0


//general
`define inst_size 31:0
`define rs2     24:20
`define rs1     19:15
`define rd      11:7
`define opcode  6:0
`define NOP     32'h00000013
//R type
`define R_type  7'b0110011
`define OP_ADD  7'b0110011
`define OP_SUB  7'b0110011
`define OP_SLL  7'b0110011
`define OP_SLT  7'b0110011
`define OP_XOR  7'b0110011
`define OP_SRL  7'b0110011
`define OP_OR   7'b0110011
`define OP_AND  7'b0110011
`define func7   31:25     
`define func3   14:12
//I type 
`define OP_LW   7'b0000011
`define I_type  7'b0010011
`define OP_ADDI 7'b0010011
`define OP_NOP  7'b0010011
`define OP_SLTI 7'b0010011
`define OP_XORI 7'b0010011
`define OP_ANDI 7'b0010011
`define OP_SLLI 7'b0010011
`define OP_SRLI 7'b0010011
`define OP_JALR 7'b1100111
`define I_imm   31:20
`define I_SL    24:20
//S type 
`define S_type  7'b0100011
`define OP_SW   7'b0100011
`define S_immM  31:25
`define S_immL  11:7
//B-type
`define B_type  7'b1100011
`define OP_BEQ  7'b1100011
`define OP_BNE  7'b1100011
`define B_imm12 31 
`define B_imm10 30:25
`define B_imm4  11:8
`define B_imm11 7
//U type 
`define U_type  7'b0110111
`define OP_LUI  7'b0110111
`define OP_AUPC 7'b0010111
`define U_imm   31:12
//J type
`define J_type  7'b1101111
`define OP_JAL  7'b1101111
`define J_imm20 31
`define J_imm10 30:21
`define J_imm11 20
`define J_imm19 19:12
//ALU func
`define ALU_si  4
`define ALU_ADD  `ALU_si'd0
`define ALU_SLL  `ALU_si'd1
`define ALU_SLT  `ALU_si'd2
`define ALU_SLTU `ALU_si'd3
`define ALU_XOR  `ALU_si'd4
`define ALU_SRL  `ALU_si'd5
`define ALU_OR   `ALU_si'd6
`define ALU_AND  `ALU_si'd7
`define ALU_SUB  `ALU_si'd8
`define ALU_EQU  `ALU_si'd9
`define ALU_NEQ  `ALU_si'd10
`define ALU_SRA  `ALU_si'd13

`endif
