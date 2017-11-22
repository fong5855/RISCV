module mux4to1 
  #(
    size=32
  )
  ( 
    output logic [size-1:0] Y,
    input [size-1:0] I0, I1, I2, I3,
    input [1:0] S
  );

  assign Y = (S == 2'b00)? I0 :
             (S == 2'b01)? I1 :
             (S == 2'b10)? I2 : I3;
  
endmodule
