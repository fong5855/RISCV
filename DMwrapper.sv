module DMwrapper
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

  logic [1:0] state, n_state;
  parameter wait_state = 2'b00;
  parameter init_state = 2'b01;
  parameter sent_state = 2'b10;
  parameter end_state = 2'b11;
  
  always_comb begin // next state logic
    case (state)
      wait_state: begin
        n_state = (HGrant)? init_state : wait_state;
      end
      init_state: begin
        n_state = (HReady && HGrant)? sent_state : init_state;
      end
      sent_state: begin
        n_state = (!HGrant && HReady)? end_state : sent_state;
      end
      end_state: begin
        n_state = (HReady && !Req)? wait_state : end_state;
      end
      default: begin
        n_state = wait_state;
      end
    endcase
  end // next state logic

  // FSM
  always_ff @(posedge clk) 
  begin
    if (rst) begin
      state <= wait_state;
    end
    else begin
      state <= n_state;
    end
  end

  // Bus signal reg
  logic [31:0] temp_read;
  always_ff @(posedge clk) begin // bus data
    if (state == sent_state) begin
      temp_read <= HRead_data;
    end
  end // bus data

  always_comb begin // output logic
    case (state)
      wait_state: begin
        // AHB
        HAddress = 32'b0;
        HWrite_data = 32'b0;
        HTrans = 2'b10;
        HSize = 3'b010;
        HLock = 1'b0;
        HReq = Req;
        HWrite = Write;
        // CPU
        Read_data = 32'b0;
        store = (Req == 1);
      end
      init_state: begin
        // AHB
        HAddress = 32'b0;
        HWrite_data = 32'b0;
        HTrans = 2'b10;
        HSize = 3'b010;
        HLock = 1'b0;
        HReq = 1'b1;
        HWrite = Write;
        // CPU
        Read_data = 32'b0;
        store = 1'b1;
      end
      sent_state: begin
        // AHB
        HAddress = Address;
        HWrite_data = Write_data;
        HTrans = 2'b10;
        HSize = 3'b010;
        HLock = 1'b0;
        HReq = 1'b0;
        HWrite = Write;
        // CPU
        Read_data = (HReady == 1)? HRead_data : 32'b0;
        store = (HReady == 1)? 1'b1 : 1'b1;
      end
      end_state: begin
        // AHB
        HAddress = 32'b0;
        HWrite_data = 32'b0;
        HTrans = 2'b10;
        HSize = 3'b010;
        HLock = 1'b0;
        HReq = 1'b0;
        HWrite = Write;
        // CPU
        Read_data = (HReady == 1)? temp_read : 32'b0;
        store = 1'b0;
      end
      default: begin
        // AHB
        HAddress = 32'b0;
        HWrite_data = 32'b0;
        HTrans = 2'b10;
        HSize = 3'b010;
        HLock = 1'b0;
        HReq = Req;
        HWrite = Write;
        // CPU
        Read_data = 32'b0;
        store = (Req == 1);
      end
    endcase
  end // output logic

endmodule 
