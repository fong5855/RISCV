
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
    
    // mem
    input [31:0] MRead_data,
    input clk,
    input rst
  );

  logic addr_error;
  logic [31:0] temp_addr, temp_data;
  
  always_comb begin
    Mwrite = HWrite;
    Menable = 1'b1;
    MAddress = {14'b0, HAddress[17:0]};
    addr_error = 1'b0;
    // read
    HRead_data = MRead_data;
    HReady = 1'b1;
    HResp = addr_error;
    // write
    MWrite_data = HWrite_data;
  end 
endmodule
