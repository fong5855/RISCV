module WaitStateCtr (
    input Load,
    input [1:0] LoadValue,
    output Carry,
    input clk
    );
  
logic [1:0] count;

always_ff @(posedge clk) begin // counter
  if (Load) begin
    count = LoadValue;
  end
  else begin
    count = count - 2'b1;
  end
end // counter

always_comb begin // carry
  Carry = (count == 2'b0);
end // carry

endmodule
