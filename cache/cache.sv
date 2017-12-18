`include "./cache_def.svh"
`include "./Comparator.sv"
`include "./Control.sv"
`include "./DataMux.sv"
`include "./ValidRam.sv"
`include "./WaitStateCtr.sv"
`include "./data_array.v"
`include "./tag_array.v"

module cache (
    input  P_strobe,
    input  [`CADDR] P_address,
    input  [`CDATA] P_data_in,
    output logic [`CDATA] P_data_out,
    input  P_rw,
    output logic P_ready,

    output logic S_strobe,
    output logic [`CADDR] S_address,
    input  [`CDATA] S_data_in,
    output logic [`CDATA] S_data_out,
    output logic S_rw,

    input rst,
    input clk
    );
/*****************************************************************************
*                                  logics                                   *
*****************************************************************************/
logic P_dataOE;
logic S_dataOE;
logic [`CDATA] P_data_reg;
logic [`TAG] TagRam_Tag;

logic [`CDATA] DataRam_Data_out;
logic [`CDATA] DataRam_Data_in;
/*****************************************************************************
*                             interconnections                              *
*****************************************************************************/
always_comb begin // mul
  P_data_out = (P_dataOE)? P_data_reg : 'bz;
  S_data_out = (S_dataOE)? P_data_in : 'bz;
  S_address = P_address;
end // mul

tag_array TagRam _in(
    .A   (P_address[`INDEX]),
    .DI  (P_address[`TAG]),
    .DO  (TagRam_Tag[`TAG]),
    .WEB (Write),
    .CS  (1'b1),
    .OE  (1'b1),
    .CK  (clk)
    );

ValidRam ValidRam (
    .Address              (P_address[`INDEX]),
    .Valid                (1'b1),
    .Valid_out            (Valid),
    .Write                (Write),
    .rst                  (rst),
    .clk                  (clk)
    );

DataMux CacheDataInputMux (
    .S                    (Cache_data_select),
    .A                    (S_data_in),
    .B                    (P_data_in),
    .Z                    (DataRam_Data_in)
    );
DataMux  PDataMux (
    .S                    (P_data_select),
    .A                    (S_data_in),
    .B                    (DataRam_Data_out),
    .Z                    (P_data_reg)
    );

data_array DataRam (
    .A   (P_address[`INDEX]),
    .DI  (DataRam_Data_in),
    .DO  (DataRam_Data_out),
    .WEB (Write),
    .CS  (1'b1),
    .OE  (1'b1),
    .CK  (clk)
    );

Comparator Comparator (
    .Tag1                 (P_address[`TAG]),
    .Tag2                 (TagRam_Tag),
    .Match                (Match)
    );

Control Control (
    .P_strobe             (P_strobe),
    .P_rw                 (P_rw),
    .P_ready              (P_ready),
    .Match                (Match),
    .Valid                (Valid),
    .Cache_data_select    (Catch_data_select),
    .P_dataOE             (P_dataOE),
    .S_strobe             (S_strobe),
    .S_rw                 (S_rw),
    .rst                  (rst),
    .clk                  (clk)
    );
         
endmodule 
         
