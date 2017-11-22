module mux2to1 
  #(  
    parameter size=32  
  )
  (
    output logic [size-1:0] Y,
    input [size-1:0] I0, I1,
    input S 
  );

  assign Y = (S==1'b1)? I1 : I0;
  
endmodule
