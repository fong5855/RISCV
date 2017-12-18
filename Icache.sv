module Icache (
    // cache
    output logic P_strobe,
    output logic P_addr,
    input [31:0] P_data,
    input P_ready,
    output logic P_rw,
    // CPU
    input [31:0] I_addr,
    input IM_enable,
    output logic [31:0] IM_out,
    output logic stall,
    
    input clk,
    input rst
    );
    
logic strobe;

always_ff @(posedge clk) begin // strobe
  if (rst) begin
    strobe <= 1'b0;
    // P_data <= 32'b0; // useless in Icache
    P_rw   <= 1'b1;  // always read
    IM_out <= 32'h13;
    P_addr <= 32'b0;
  end
  else begin
    strobe <= IM_enable;
    // P_data <= 32'b0; // useless in Icache
    P_rw   <= 1'b1;  // always read
    if (P_ready) begin
      IM_out <= P_data;
      stall  <= 1'b0;
    end
    else begin
      P_addr <= I_addr;
      stall  <= 1'b1;
    end
  end
end // strobe

endmodule
