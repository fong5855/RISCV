`ifndef CDEF
`define CDEF 0

`define CREAD      1
`define CWRITE     0
`define CACHE_SIZE 1024
`define WAITSTATES 2

`define CADDR      15:0
`define DATA_WIDTH 32
`define CDATA      `DATA_WIDTH-1:0
`define INDEX      9:0
`define TAG        15:10

`define PRESENT 1
`define ABSENT !`PRESENT

// control state
`define STATE_IDLE      4'd0
`define STATE_READ      4'd1
`define STATE_READMISS  4'd2
`define STATE_READSYS   4'd3
`define STATE_READDATA  4'd4
`define STATE_WRITE     4'd5
`define STATE_WRITEHIT  4'd6
`define STATE_WRITEMISS 4'd7
`define STATE_WRITESYS  4'd8
`define STATE_WRITEDATA 4'd9

`endif 
