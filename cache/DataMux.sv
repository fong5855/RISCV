module DataMux (
    input S,
    input [`CDATA] A,
    input [`CDATA] B,
    output logic [`CDATA] Z,
    );

always_comb begin // Mux
  if (A) begin
    Z = A;
  end
  else begin
    Z = B;
  end
end // Mux
  
endmodule
