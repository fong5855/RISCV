module Comparator (
    input [`TAG] Tag1,
    input [`TAG] Tag2,
    output logic Match
    );

always_comb begin // compare
  if (Tag1 == Tag2) begin
    Match = 1'b1;
  end
  else begin
    Match = 1'b0;
  end
end // compare 

endmodule
