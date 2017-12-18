module Cache_SYS (
    // to Bus
    output logic [31:0] HAddress,
    output logic [31:0] HWrite_data,
    output logic [`AHB_TRANS_BITS-1:0] HTrans,
    output logic [`AHB_SIZE_BITS-1:0] HSize,
    output logic HLock,
    output logic HReq,
    output logic HWrite,

    // to cache 
    output logic [31:0] Read_data,
    output logic M_ready,

    // from Bus
    input [31:0] HRead_data,
    input [1:0] HResp,
    input HReady,
    input HGrant,

    // from CPU
    input [31:0] Address,
    input [31:0] Write_data,
    input Write,
    input Req,

    // clk, rst
    input clk,
    input rst
    );

  logic [31:0] temp_read;
  logic [1:0] state, n_state;
  parameter IDEL = 2'd0;
  parameter ADDR = 2'd1;
  parameter DATA = 2'd2;
  parameter END  = 2'd3;
  
  always_comb begin // next state logic
    case (state)
      IDEL: begin
        n_state = (HGrant)? ADDR : IDEL;
      end
      ADDR: begin
        n_state = (HReady && HGrant)? DATA : ADDR;
      end
      DATA: begin
        n_state = (/*stall && */HReady)? END : (/*~stall && */HReady)? IDEL : DATA;
      end
      END: begin
        // n_state = (~stall)? IDEL : END;
        n_state = IDEL;
      end
      default: begin
        n_state = IDEL;
      end
    endcase
  end // next state logic

  // FSM
  always_ff @(posedge clk) 
  begin
    if (rst) begin
      state <= IDEL;
    end
    else begin
      state <= n_state;
    end
  end

  
  always_ff @(posedge clk) begin //reg
    case (state)
      DATA: begin
        temp_read <= HRead_data;
      end
      END:begin
        temp_read <= temp_read;
      end
      default: begin
        temp_read <= 32'b0;
      end
    endcase
  end //reg

  always_comb begin // Mealy Machine output logic
    case (state)
      IDEL: begin
        HReq        <= Req;
        HAddress    <= 32'b0;
        HWrite      <= 1'b0;
        HWrite_data <= 32'b0;
        M_ready     <= ~Req;
        HLock       <= 1'b0;
        HTrans      <= 3'b010;
        HSize       <= 3'b010;
        Read_data   <= 32'b0;
      end
      ADDR: begin
        HReq        <= 1'b0;
        HAddress    <= Address;
        HWrite      <= Write;
        HWrite_data <= Write_data;
        M_ready     <= 1'b0;
        HLock       <= 1'b0;
        HTrans      <= 3'b010;
        HSize       <= 3'b010;
        Read_data   <= 32'b0;
      end
      DATA: begin
        HReq        <= ~HReady;//1'b0;
        HAddress    <= 32'b0;
        HWrite      <= 1'b0;
        HWrite_data <= 1'b0;
        M_ready     <= HReady;
        HLock       <= 1'b0;
        HTrans      <= 3'b010;
        HSize       <= 3'b010;
        Read_data   <= HRead_data;
      end
      END: begin
        HReq        <= 1'b0;
        HAddress    <= 32'b0;
        HWrite      <= 1'b0;
        HWrite_data <= 1'b0;
        M_ready     <= 1'b1;
        HLock       <= 1'b0;
        HTrans      <= 3'b010;
        HSize       <= 3'b010;
        Read_data   <= temp_read;
      end
      default: begin
        HReq        <= 1'b0;
        HAddress    <= 32'b0;
        HWrite      <= 1'b0;
        HWrite_data <= 1'b1;
        M_ready     <= 1'b1;
        HLock       <= 1'b0;
        HTrans      <= 3'b010;
        HSize       <= 3'b010;
        Read_data   <= 32'b0;
      end
    endcase
  end // Mealy Machine output logic
  
endmodule
