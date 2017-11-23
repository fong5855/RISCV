module forwarding 
  (
   input [6:0] op,
   input regWrite_s5, 
   input regWrite_s4,
   input [4:0] rd_s5,
   input [4:0] rd_s4,

   input [4:0] src1,
   input [4:0] src2,

   output logic [1:0] forward1,
   output logic [1:0] forward2
  );
  parameter s4_ = 2'b10;
  parameter s5_ = 2'b01;
  parameter no_ = 2'b00;

  always_comb begin   // forward1
    if (op != `OP_AUPC && op != `U_type && op != `J_type) begin
      if (regWrite_s4 && rd_s4 != 0 && rd_s4 == src1) begin
        forward1 = s4_;
      end
      else if (regWrite_s5 && rd_s5 != 0 && rd_s5 == src1) begin
        forward1 = s5_;
      end
      else begin
        forward1 = no_;
      end
    end
    else begin
      forward1 = no_;
    end
  end // forward1

  always_comb begin // forward2
    if (op != `I_type && op != `U_type && op != `J_type && op != `OP_LW && op != `OP_JALR && op != `OP_AUPC) begin
      if (regWrite_s4 && rd_s4 != 0 && rd_s4 == src2) begin
        forward2 = s4_;
      end
      else if (regWrite_s5 && rd_s5 != 0 && rd_s5 == src2) begin
        forward2 = s5_;
      end
      else begin
        forward2 = no_;
      end
    end
    else begin
      forward2 = no_;
    end
  end // forward2
  
endmodule
