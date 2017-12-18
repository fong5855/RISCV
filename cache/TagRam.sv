module TagRam (
    input Address,
    input TagIn,
    output logic [`TAG] TagOut,
    input Write,
    input clk
    );

always_ff @(posedge clk) begin // Write logic 
  if (Write) begin
    TagRam
  end
end // Write logic 
  
endmodule
