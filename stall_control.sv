module stall_control 
(
 output logic cpu_stall,

 input IM_enable,
 input DM_enable,
 input IM_ready,
 input DM_ready
 );

logic IM_stall, DM_stall;

always_comb begin // stall control logic
  if (IM_enable) begin
    IM_stall = ~IM_ready;
  end
  else begin
    IM_stall = 1'b0;
  end
  if (DM_enable) begin
    DM_stall = ~DM_ready;
  end
  else begin
    DM_stall = 1'b0;
  end
  cpu_stall = IM_stall | DM_stall;
end // stall control logic

endmodule
