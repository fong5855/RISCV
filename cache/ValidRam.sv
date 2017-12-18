module ValidRam (
    input [`INDEX] Address,
    input Valid,
    output logic Valid_out,
    input rst,
    input clk
    );

integer i;
logic [`CACHE_SIZE-1 : 0] Valid_bits; 

always_ff @(posedge clk) begin // Write
  if (Write) begin
    Valid_bits[Address] = Valid;
  end
  else if (rst) begin
    for(i=0; i<`CACHE_SIZE; i = i+1)
      Valid_bits[i] = `ABSENT;
  end
end // Write

always_ff @(posedge clk) begin // Read
  Valid_out = Valid_bits;
end // Read
  
endmodule
