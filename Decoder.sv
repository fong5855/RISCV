//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    Decoder.sv
// Description: Decode which slave to select
// Version:     1.0
//================================================

module Decoder(
  input [`AHB_ADDR_BITS-1:0] HADDR,
  output logic HSELDefault,
  output logic HSEL_S1,
  output logic HSEL_S2
);
  
  always_comb/* complete by yourself */
    begin
      case(HADDR[`AHB_ADDR_BITS-1:`AHB_ADDR_BITS-4])
        4'b0001:begin
           HSEL_S1     = 1'b1;
           HSEL_S2     = 1'b0;
           HSELDefault = 1'b0;
        end
        4'b0010:begin
          HSEL_S1     = 1'b0;
          HSEL_S2     = 1'b1;
          HSELDefault = 1'b0;
        end
        default:begin
          HSEL_S1     = 1'b0;
          HSEL_S2     = 1'b0;
          HSELDefault = 1'b1;
        end
      endcase
    end
endmodule
