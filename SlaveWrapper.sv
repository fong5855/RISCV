
module SlaveWrapper 
  (
    output logic [31:0] HRead_data,
    output logic [1:0] HResp,
    output logic HReady,
    // mem
    output logic [31:0] MAddress,
    output logic [31:0] MWrite_data,
    output logic Mwrite,
    output logic Menable,

    input [31:0] HAddress,
    input [31:0] HWrite_data,
    input HWrite,
    input HSel,
    input HGrant,
    
    // mem
    input [31:0] MRead_data,
    input clk,
    input rst
  );

  logic addr_error;
  logic [31:0] temp_addr, temp_data;
  logic temp_write, temp_en;
  always_ff @(posedge clk) begin // data reg
    if (rst) begin
      temp_addr <= 32'b0;
      temp_data <= 32'b0;
      temp_write <= 1'b0;
      temp_en   <= 1'b0;
    end
    else if (HGrant) begin
      temp_addr <= HAddress;
      temp_data <= HWrite_data;
      temp_write <= HWrite;
      temp_en   <= HSel;
    end
    else begin
      temp_addr <= temp_addr;
      temp_data <= temp_data;
      temp_write <= temp_write;
      temp_en   <= temp_en;
    end
  end // data reg

  always_comb begin
    Mwrite = temp_write;
    Menable = temp_en;
    MAddress = temp_addr; //{14'b0, HAddress[17:0]};
    // addr_error = 1'b0;
    // read
    HRead_data = MRead_data;
    HReady = 1'b1;
    HResp = (HSel == 1)? 2'b10:2'b0;
    // write
    MWrite_data = temp_data;
  end 
endmodule
