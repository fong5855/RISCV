module reg_32x32
  #(
    parameter ADSize=5,
    parameter REGSize=32,
    parameter DASize=32
  )
  (
    output logic [REGSize-1:0] OUT_1, 
    output logic [REGSize-1:0] OUT_2,
    input Write,
    input [ADSize-1:0] Read_ADDR_1, Read_ADDR_2, Write_ADDR,
    input [DASize-1:0] DIN,
    input enable, clk, rst
  );

  // 32 x 32 regster
  logic [DASize-1:0] mem [REGSize-1:0];
  integer i;
  always_comb
  begin
    OUT_1 = mem[Read_ADDR_1][31:0];
    OUT_2 = mem[Read_ADDR_2][31:0];
  end

  always_ff@(negedge clk or  posedge rst)
  begin
    if(rst == 1)
    begin
      for(i=0; i < REGSize; i=i+1)
      begin
        mem[i] <= 32'd0;
      end
    end
    else
    begin
      if(Write == 1 && enable == 1)
      begin
        if(Write_ADDR != 5'b0)
          mem[Write_ADDR][31:0] <= DIN;
      end
    end
  end
endmodule
