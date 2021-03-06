//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    MuxM2S.sv
// Description: Master to slave multiplexer
// Version:     1.0
//================================================
module MuxM2S(
  input HCLK,
  input HRESETn,
  input [`AHB_MASTER_BITS-1:0] HMASTER,
  input HREADY,

  input [`AHB_ADDR_BITS-1:0] HADDR_M1,
  input [`AHB_TRANS_BITS-1:0] HTRANS_M1,
  input HWRITE_M1,
  input [`AHB_SIZE_BITS-1:0] HSIZE_M1,
  input [`AHB_DATA_BITS-1:0] HWDATA_M1,

  input [`AHB_ADDR_BITS-1:0] HADDR_M2,
  input [`AHB_TRANS_BITS-1:0] HTRANS_M2,
  input HWRITE_M2,
  input [`AHB_SIZE_BITS-1:0] HSIZE_M2,
  input [`AHB_DATA_BITS-1:0] HWDATA_M2,

  output logic [`AHB_ADDR_BITS-1:0] HADDR,
  output logic [`AHB_TRANS_BITS-1:0] HTRANS,
  output logic HWRITE,
  output logic [`AHB_SIZE_BITS-1:0] HSIZE,
  output logic [`AHB_DATA_BITS-1:0] HWDATA
);

  logic [`AHB_MASTER_BITS-1:0] MasterPrev;

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      MasterPrev <= #1 `AHB_MASTER_BITS'd0;
    else if (HREADY)
      MasterPrev <= #1 HMASTER;
  end

  always_comb // HADDR
  begin
    /* complete this part by yourself */
    case(HMASTER)
      4'b0001:begin
        HADDR = HADDR_M1;
      end
      4'b0010:begin
        HADDR = HADDR_M2;
      end
      default:begin
        HADDR = `AHB_ADDR_BITS'b0;
      end
    endcase
  end

  always_comb // HTRANS
  begin
    /* complete this part by yourself */
    case(HMASTER)
      4'b0001:begin
        HTRANS = HTRANS_M1;
      end
      4'b0010:begin
        HTRANS = HTRANS_M2;
      end
      default:begin
        HTRANS = `AHB_TRANS_BITS'b0;
      end
    endcase
  end

  always_comb // HWRITE
  begin
    /* complete this part by yourself */
    case(HMASTER)
      4'b0001:begin
        HWRITE = HWRITE_M1;
      end
      4'b0010:begin
        HWRITE = HWRITE_M2;
      end
      default:begin
        HWRITE = 1'b0;
      end
    endcase    
  end

  always_comb // HSIZE
  begin
    /* complete this part by yourself */
    case(HMASTER)
      4'b0001:begin
        HSIZE = HSIZE_M1;
      end
      4'b0010:begin
        HSIZE = HSIZE_M2;
      end
      default:begin
        HSIZE = `AHB_SIZE_BITS'b0;
      end
    endcase   
  end

  always_comb // HWDATA
  begin
    /* complete this part by yourself */
    case(HMASTER)
      4'b0001:begin
        HWDATA = HWDATA_M1;
      end
      4'b0010:begin
        HWDATA = HWDATA_M2;
      end
      default:begin
        HWDATA = `AHB_DATA_BITS'b0;
      end
    endcase   
  end
endmodule
