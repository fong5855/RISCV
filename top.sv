`include "AHB_def.svh"
`include "def.sv"
`include "CPU.sv"
`include "./hazard.sv"
`include "./forwarding.sv"
`include "sign_extend.sv"
`include "./mux2to1.sv"
`include "./mux4to1.sv"
`include "./alu_control.sv"
`include "./control.sv"
`include "./reg_32x32.sv"
`include "./ALU.sv"
`include "SlaveWrapper.sv"
`include "CPUwrapper.sv"
`include "AHB.sv"
`include "./Cache_SYS.sv"
`include "./Icache.sv"
`include "stall_control.sv"
`include "./IMwrapper.sv"
`include "./cache/cache.sv"
`include "./cache/cache_def.svh"


module top(
  input clk,
  input rst,
  input [31:0] IM_out,
  input [31:0] DM_out,
  output IM_enable,
  output [31:0] IM_address,
  output DM_write,
  output DM_enable,
  output [31:0] DM_in,
  output [31:0] DM_address
);

    logic [31:0] HADDR_M1;
    logic [1:0] HTRANS_M1;
    logic HWRITE_M1;
    logic [2:0] HSIZE_M1;
    logic [31:0] HWDATA_M1;
    logic HBUSREQ_M1;
    logic HLOCK_M1;

    logic [31:0] HADDR_M2;
    logic [1:0] HTRANS_M2;
    logic HWRITE_M2;
    logic [2:0] HSIZE_M2;
    logic [31:0] HWDATA_M2;
    logic HBUSREQ_M2;
    logic HLOCK_M2;

    logic [31:0] HRDATA_S1;
    logic HREADY_S1;
    logic [1:0] HRESP_S1;

    logic [31:0] HRDATA_S2;
    logic HREADY_S2;
    logic [1:0] HRESP_S2;

    logic [31:0] HRDATA;
    logic HREADY;
    logic [1:0] HRESP;
    logic HGRANT_M1;
    logic HGRANT_M2;

    logic [1:0] HTRANS;
    logic [31:0] HADDR;
    logic HWRITE;
    logic [2:0] HSIZE;
    logic [31:0] HWDATA;
    logic [3:0] HMASTER;
    logic HMASTLOCK;
    logic HSEL_S1;
    logic HSEL_S2;    

  logic [31:0] m1_out;
  logic [31:0] m1_addr;
  logic m1_en;
  logic [31:0] m2_out;
  logic [31:0] m2_addr;
  logic [31:0] m2_in;
  logic m2_write;
  logic m2_en;
  logic cpu_stall;

  // cache
  logic P_strobe, P_rw, P_ready, S_strobe, S_rw;
  logic [`CADDR] P_address, S_address;
  logic [`CDATA] P_data_in, P_data_out, S_data_in, S_data_out;


  CPU CPU1 (
      .clk(clk),
      .rst(rst),
    .IM_address(m1_addr),
    .IM_enable(m1_en),
    .IM_out(m1_out),

    .DM_address(m2_addr),
    .DM_in(m2_in),
    .DM_enable(m2_en),
    .DM_write(m2_write),
    .DM_out(m2_out),

    .stall(cpu_stall)
  );

  Icache Icache_wrapper(
      .P_strobe (P_strobe),
      .P_addr (P_addr),
      .P_data (P_data_out),
      .P_ready (P_ready),
      .P_rw (P_rw),
      // CPU
      .I_addr (m1_addr),
      .IM_enable (m1_en),
      .IM_out (m1_out),
      .stall (m1_ready),
      .clk (clk),
      .rst (rst)
      );

  cache I_Cache(
      .P_strobe (P_strobe),
      .P_address (P_address),
      .P_data_in (P_data_in),
      .P_data_out (P_data_out),
      .P_rw (P_rw),
      .P_ready (P_ready),

      .S_strobe (S_strobe),
      .S_address (S_address),
      .S_data_in (S_data_in),
      .S_data_out (S_data_out),
      .S_rw (S_rw),

      .rst (rst),
      .clk (clk)
      );
  
  Cache_SYS iCache_SYS(
      // Bus output
      .HAddress(HADDR_M1),
      .HWrite_data(HWDATA_M1),
      .HTrans(HTRANS_M1),
      .HSize(HSIZE_M1),
      .HLock(HLOCK_M1),
      .HReq(HBUSREQ_M1),
      .HWrite(HWRITE_M1),

      // CPU output
      .Read_data(P_data_in),
      .M_ready(),

      // Bus input
      .HRead_data(HRDATA), 
      .HResp(HRESP),
      .HReady(HREADY), // HREADY_S1
      .HGrant(HGRANT_M1),

      // cpu input
      .Address(P_address),
      .Write_data(32'b0),
      .Write(1'b0),
      .Req(S_strobe),
      // .DM_en(m2_en),
      // .stall(cpu_stall),

      // clk
      .clk(clk),
      .rst(rst)
      );

  AHB ahb(
        .HCLK(clk),
        .HRESETn(~rst),

        .HADDR_M1(HADDR_M1),
        .HTRANS_M1(HTRANS_M1),
        .HWRITE_M1(HWRITE_M1),
        .HSIZE_M1(HSIZE_M1),
        .HWDATA_M1(HWDATA_M1),
        .HBUSREQ_M1(HBUSREQ_M1),
        .HLOCK_M1(HLOCK_M1),

        .HADDR_M2(HADDR_M2),
        .HTRANS_M2(HTRANS_M2),
        .HWRITE_M2(HWRITE_M2),
        .HSIZE_M2(HSIZE_M2),
        .HWDATA_M2(HWDATA_M2),
        .HBUSREQ_M2(HBUSREQ_M2),
        .HLOCK_M2(HLOCK_M2),

        .HRDATA_S1(HRDATA_S1),
        .HREADY_S1(HREADY_S1),
        .HRESP_S1(HRESP_S1),
        
        .HRDATA_S2(HRDATA_S2),
        .HREADY_S2(HREADY_S2),
        .HRESP_S2(HRESP_S2),

        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .HGRANT_M1(HGRANT_M1),
        .HGRANT_M2(HGRANT_M2),
        
        .HTRANS(HTRANS),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HWDATA(HWDATA),
        .HMASTER(HMASTER),
        .HMASTLOCK(HMASTLOCK),
        .HSEL_S1(HSEL_S1),
        .HSEL_S2(HSEL_S2)
      );

  // IMwrapper M_IM(
      // // Bus output
      // .HAddress(HADDR_M1),
      // .HWrite_data(HWDATA_M1),
      // .HTrans(HTRANS_M1),
      // .HSize(HSIZE_M1),
      // .HLock(HLOCK_M1),
      // .HReq(HBUSREQ_M1),
      // .HWrite(HWRITE_M1),

      // // CPU output
      // .Read_data(m1_out),
      // .M_ready(m1_ready),

      // // Bus input
      // .HRead_data(HRDATA), 
      // .HResp(HRESP),
      // .HReady(HREADY), // HREADY_S1
      // .HGrant(HGRANT_M1),

      // // cpu input
      // .Address(m1_addr),
      // .Write_data(32'b0),
      // .Write(1'b0),
      // .Req(m1_en),
      // // .DM_en(m2_en),
      // .stall(cpu_stall),

      // // clk
      // .clk(clk),
      // .rst(rst)

      // );

  stall_control stall_control(
      .cpu_stall(cpu_stall),
      .IM_enable(m1_en),
      .DM_enable(m2_en),
      .IM_ready(~m1_ready),
      .DM_ready(m2_ready)
      );

  IMwrapper M_DM(
      .HAddress(HADDR_M2),
      .HWrite_data(HWDATA_M2),
      .HTrans(HTRANS_M2),
      .HSize(HSIZE_M2),
      .HLock(HLOCK_M2),
      .HReq(HBUSREQ_M2),
      .HWrite(HWRITE_M2),

      .Read_data(m2_out),
      .M_ready(m2_ready),

      .HRead_data(HRDATA),
      .HResp(HRESP),
      .HReady(HREADY_S2),
      .HGrant(HGRANT_M2),

      // cpu input
      .Address(m2_addr),
      .Write_data(m2_in),
      .Write(m2_write),
      .Req(m2_en),
      .stall(cpu_stall),

      // clk
      .clk(clk),
      .rst(rst)
      );

  SlaveWrapper S_IM(
      // Bus output
      .HRead_data(HRDATA_S1),
      .HResp(HRESP_S1),
      .HReady(HREADY_S1),
      
      // MEM output
      .MAddress(IM_address),
      .MWrite_data(),
      .Mwrite(),
      .Menable(IM_enable),

      // Bus input
      .HAddress(HADDR),
      .HWrite_data(HWDATA),
      .HWrite(HWRITE),
      .HSel(HSEL_S1),
      .HGrant(HGRANT_M1),

      // MEM input
      .MRead_data(IM_out),

      .clk(clk),
      .rst(rst)
      );

  SlaveWrapper S_DM(
      .HRead_data(HRDATA_S2),
      .HResp(HRESP_S2),
      .HReady(HREADY_S2),

      .MAddress(DM_address),
      .MWrite_data(DM_in),
      .Mwrite(DM_write),
      .Menable(DM_enable),

      .HAddress(HADDR),
      .HWrite_data(HWDATA),
      .HWrite(HWRITE),
      .HSel(HSEL_S2),
      .HGrant(HGRANT_M2),

      .MRead_data(DM_out),

      .clk(clk),
      .rst(rst)
      );

endmodule
