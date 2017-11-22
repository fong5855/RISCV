module CPUwrapper
  #(
      parameter sel = 4'b1
      )
  (
    output logic [31:0] HAddress,
    output logic [31:0] HWrite_data,
    output logic [`AHB_TRANS_BITS-1:0] HTrans,
    output logic [`AHB_SIZE_BITS-1:0] HSize,
    output logic HLock,
    output logic HReq,
    output logic HWrite,

    // CPU
    output logic [31:0] Read_data,
    output logic store,

    input [31:0] HRead_data,
    input [1:0] HResp,
    input HReady,
    input HGrant,

    // CPU
    input [31:0] Address,
    input [31:0] Write_data,
    input Write,
    input Req,

    // clk
    input clk,
    input rst
  );

  logic state, n_state;
  parameter data_state = 1'b0;
  parameter addr_state = 1'b1;

  always_ff @(negedge clk) 
  begin
    if (rst) 
      state <= addr_state;
    else
      state <= n_state;
  end 

  logic [31:0] temp_addr, temp_data;
  logic temp_write;

  always_ff @(negedge clk) begin 
    if (rst == 1) begin
      temp_addr <= 32'b0;
      temp_data <= 32'b0;
    end
    else begin
      temp_addr <= Address;
      temp_data <= Write_data;
      temp_write <= Write;
    end
  end 

  always_comb 
  begin 
    if (state == addr_state && rst == 0) begin
      HReq = Req;
    end
    else begin
      HReq = 1'b0;
    end
  end 

  always_ff @(posedge clk) 
  begin 
    if (rst == 1'b1) begin
      HAddress <= 32'b0;
      n_state <= data_state;
      store <= 1'b0;
      Read_data <= 32'b0;
      HWrite <= 1'b0;
      HLock <= 1'b0;
    end
    else begin
      if (state == addr_state) begin
        if (HGrant == 1) begin
          HAddress <= {sel, temp_addr[27:0]};
          HWrite_data <= temp_data;
          HWrite <= temp_write;
          store <= 1'b1;
          n_state <= data_state;
        end
        else begin
          HAddress <= 32'b0;
          store <= (sel == 4'b1) ? 1'b1 : 1'b0;
          n_state <= n_state;
        end
      end
      else begin
        if (HReady == 1) begin
          Read_data <= HRead_data;
          n_state <= addr_state;
          store <= (sel == 4'b1) ? 1'b0 : 1'b1;
        end
        else begin
          Read_data <= HRead_data;
          n_state <= n_state;
          store <= 1'b1;
        end
      end
    end
  end 
endmodule
