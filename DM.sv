module DM(
  input clk,
  input rst,
  input DM_write,
  input DM_enable,
  input [31:0] DM_in,
  input [15:0] DM_address,
  output logic [31:0] DM_out
);

  logic [31:0] mem_data [0:65535];

  always_comb 
  begin
    if (DM_enable == 1'b1 && DM_write == 1'b0)
    begin
      DM_out = mem_data[DM_address];
    end
  end 

  always_ff @(posedge clk)
  begin 
    if (DM_enable == 1'b1 && DM_write == 1'b1)
    begin
      mem_data[DM_address] = DM_in;
    end
  end 
endmodule
