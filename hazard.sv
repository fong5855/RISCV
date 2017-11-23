module hazard(
    input [6:0] op,
    input [4:0] rs1_s3,
    input [4:0] rs1_s2,
    input [4:0] rs2_s2,

    output logic stall,
    output logic flush_s3
    );

  always_comb begin 
    if (op == `OP_LW && (rs1_s2 == rs1_s3 || rs2_s2 == rs1_s3))begin
      stall = 1'b1;
      flush_s3   = 1'b1;
    end
    else begin
      stall = 1'b0;
      flush_s3   = 1'b0;
    end
  end 
  
endmodule
