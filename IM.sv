module IM(
  input clk,
  input rst,
  input IM_write,
  input IM_enable,
  input [31:0] IM_in,
  input [15:0] IM_address,
  output logic [31:0] IM_out
);

  logic [31:0] mem_data [0:65535];

  always_comb 
  begin
    if (IM_enable == 1'b1 && IM_write == 1'b0)
    begin
      IM_out = mem_data[IM_address];
    end
  end
  
  always_ff @(posedge clk) 
  begin
    if (IM_enable == 1'b1 && IM_write == 1'b1) 
    begin
      mem_data[IM_address] = IM_in;  
    end
  end 
endmodule
