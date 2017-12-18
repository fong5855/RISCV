module Control (
    input P_strobe,
    input P_rw,
    output logic P_ready,
    input Match,
    input Valid,
    output logic Write,
    output logic Cache_data_select,
    output logic P_data_select,
    output logic S_dataOE,
    output logic P_dataOE,
    output logic S_strobe,
    output logic S_rw,
    input rst,
    input clk
    );

/*****************************************************************************
*                                  logics                                   *
**************** *************************************************************/
logic [1:0] wait_state_ctr_input = `WAITSTATES-1;
logic load_wait_state_ctr;
logic wait_state_ctr_carry;

logic p_ready_en;
logic [3:0] state, next_state;

WaitStateCtr WaitStateCtr (
    .Load      (load_wait_state_ctr),
    .LoadValue (wait_state_carry),
    .Carry     (wait_state_ctr_carry),
    .clk       (clk)
    );

always_ff @(posedge clk) begin // state machine
  if (rst) begin
    state <= `STATE_IDLE;
  end
  else begin
    state <= next_state;
  end
end // state machine

always_comb begin // next state logic 
  case (state)
    `STATE_IDLE: begin
      if (P_strobe && P_rw == `CREAD) begin
        next_state = `STATE_READ;
      end
      else if (P_strobe && P_rw == `CWRITE) begin
        next_state = `STATE_WRITE;
      end
      else begin
        next_state = `STATE_IDLE;
      end
    end

    `STATE_READ: begin
      if (Match && Valid) begin
        next_state = `STATE_IDLE;
      end
      else begin
        next_state = `STATE_READMISS;
      end
    end

    `STATE_READMISS: begin
      next_state = `STATE_READSYS;
    end

    `STATE_READSYS: begin
      if (wait_state_ctr_carry) begin
        next_state = `STATE_READDATA;
      end
      else begin
        next_state = `STATE_READSYS;
      end
    end

    `STATE_READDATA: begin
      next_state = `STATE_IDLE;
    end
    
    `STATE_WRITE: begin
      if (Match && Valid) begin
        next_state = `STATE_WRITEHIT;
      end
      else begin
        next_state = `STATE_WRITEMISS;
      end
    end
    
    `STATE_WRITEHIT: begin
      next_state = `STATE_WRITESYS;
    end

    `STATE_WRITEMISS: begin
      next_state = `STATE_WRITESYS;
    end

    `STATE_WRITESYS: begin
      if (wait_state_ctr_carry) begin
        next_state = `STATE_WRITEDATA;
      end
      else begin
        next_state = `STATE_WRITESYS;
      end
    end

    `STATE_WRITEDATA: begin
      next_state = `STATE_IDLE;
    end

    default: begin
      next_state = `STATE_IDLE;
    end
  endcase
end // next state logic 
  
task OutputVec;
input [9:0] vector;
begin
  {load_wait_state_ctr, p_ready_en, P_ready, Write, S_strobe, S_rw, Cache_data_select, P_data_select, P_dataOE, S_dataOE} = vector;
end
endtask

always_comb begin // output logic
  case (state)
    `STATE_IDLE: begin
      OutputVec(10'b00_0000_0000);
    end
    `STATE_READ: begin
      OutputVec(10'b01_0000_0010);
    end
    `STATE_READMISS: begin
      OutputVec(10'b10_0011_0010);
    end
    `STATE_READSYS: begin
      OutputVec(10'b00_0001_0010);
    end
    `STATE_READDATA: begin
      OutputVec(10'b00_1101_1110);
    end
    `STATE_WRITE: begin
      OutputVec(10'b01_0000_0000);
    end
    `STATE_WRITEHIT: begin
      OutputVec(10'b10_0110_1100);
    end
    `STATE_WRITEMISS: begin
      OutputVec(10'b10_0010_0001);
    end
    `STATE_WRITESYS: begin
      OutputVec(10'b00_0000_0001);
    end
    `STATE_WRITEDATA: begin
      OutputVec(10'b00_1100_1101);
    end
    default: begin
      
    end
  endcase
end // output logic

always_comb begin // P_ready logic 
  P_ready = (p_ready_en && Match && Valid) || P_ready;
end // P_ready logic 

endmodule
