module ALU(
  output logic [31:0] alu_result,
  output logic Overflow,
  input  logic [31:0] src1, src2,
  input  logic enable,
  input  logic [`ALU_si-1:0] OP
    );
  always_comb
  begin
    if(enable)
    begin
      case(OP)
        `ALU_ADD:
        begin
          alu_result = src1 + src2;
          // if((alu_result[31] == 1 && src1[31] == 0 && src2[31] == 0)||(alu_result[31] == 0 && src1[31] == 1 && src2[31] == 1))
          Overflow   = ((alu_result[31] == 1 && src1[31] == 0 && src2[31] == 0)||(alu_result[31] == 0 && src1[31] == 1 && src2[31] == 1))? 1'b1 : 1'b0;
          // else Overflow = 1'b0;
        end
        `ALU_SLL:
        begin
          alu_result = src1 << src2;
          Overflow   = 1'b0;
        end
        `ALU_SLT:
        begin
          alu_result = (src1[31] == 1'b0)?((src2[31] == 1'b0)?((src1<src2)?32'b1 : 32'b0):32'b0):(src2[31] == 1'b0)?32'b1:(src1>src2)?32'b1:32'b0;
          Overflow   = 1'b0;
        end
        `ALU_XOR:
        begin
          alu_result = src1^src2;
          Overflow   = 1'b0;
        end
        `ALU_SRL:
        begin
          alu_result = src1 >> src2;
          Overflow   = 1'b0;
        end
        `ALU_OR:
        begin
          alu_result = src1 | src2;
          Overflow   = 1'b0;
        end
        `ALU_AND:
        begin
          alu_result = src1 & src2;
          Overflow   = 1'b0;
        end
        `ALU_SUB:
        begin
          alu_result = src1 - src2;
          Overflow   = ((alu_result[31] == 1 && src1[31] == 0 && src2[31] == 1)||(alu_result[31] == 0 && src1[31] == 1 && src2[31] == 0))? 1'b1 : 1'b0;
        end
        `ALU_EQU:
        begin
          alu_result = (src1 == src2)? 32'b1 : 32'b0;
          Overflow   = 1'b0;
        end
        `ALU_NEQ:
        begin
          alu_result = (src1 != src2)? 32'b1 : 32'b0;
          Overflow   = 1'b0;
        end
        default:
        begin
          alu_result = 32'b0;
          Overflow   = 1'b0;
        end
      endcase
    end
    else
    begin
      alu_result   = 32'b0;
      Overflow     = 1'b0;
    end
  end
endmodule
