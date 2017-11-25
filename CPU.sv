`include "def.sv"
module CPU
  #(
    parameter    IM_adSize=32, //[1:0] useless
    parameter    MEMSize=32
  )
  (
    //Connect with IM
    output logic [ IM_adSize-1:0] IM_address,
    output logic IM_enable,
    input  [ MEMSize-1:0] IM_out,
    
    //Connect with DM
    output logic [ MEMSize-1:0] DM_address,
    output logic [ MEMSize-1:0] DM_in,
    output logic DM_enable,
    output logic DM_write,
    input  [ MEMSize-1:0] DM_out,
    //system signals
    input  clk,
    input  rst,
    input  stall
  );
  /***************************************************************************
  *                            variable declear                             *
  ***************************************************************************/
  ////// stage 1
  logic hazard_stall;

  logic pcsrc;
  logic pc_stall;
  logic [31:0] IM_addr_s4;

  // pipe line IF/ID
  logic [`inst_size] inst_s2;
  logic [IM_adSize-1:0] pc_s2;
  logic [IM_adSize-1:0] pc4_s2;
  logic s12_stall;
  /////// stage 2
  // control
  logic [1:0] ALU_op;
  logic [1:0] DMtoReg;
  logic auipc;
  logic RegWrite, DM_en, DM_wri, jump, branch, ALU_src;

  // sign extend
  logic [31:0] se_imm; //sign extended imm

  // hazard unit
  logic hazard_flush;
  logic [4:0] rs1_s3, rs2_s3;
  logic [6:0] op_s3;

  // RegFile
  logic [31:0] rs1_data, rs2_data; 

  // pipeline ID/EXE
  logic [IM_adSize-1:0] pc_s3, pc4_s3;
  logic [31:0] se_imm_s3, rs1_data_s3, rs2_data_s3;
  logic [6:0] func7_s3;
  logic [4:0] rd_s3;
  logic [2:0] func3_s3;
  logic [1:0] ALU_op_s3, DMtoReg_s3;
  logic RegWrite_s3, DM_en_s3, DM_write_s3, jump_s3, branch_s3, ALU_src_s3, auipc_s3;
  logic hazard_or_flush;

  ////// stage 3
  // branch address
  logic [IM_adSize-1:0] imm_IM_addr;

  // forwarding
  logic [1:0] forward1, forward2;


  logic [IM_adSize-1:0] pc4_s4;

  logic [31:0] data1_s3, data1_s4;
  logic [31:0] data2_s3, data2_s4;

  // alu op
  logic [`ALU_si-1:0] alu_func;

  // alu src
  logic [31:0] alu_src1;
  logic [31:0] alu_src2;

  // alu
  logic [31:0] alu_result;

  // alu branch
  logic branch_xor;

  // pipeline EX/MEM
  logic [31:0] alu_result_s4, se_imm_s4, rs2_data_s4;
  logic DM_en_s4, DM_write_s4, jump_s4, branch_s4, branch_xor_s4;
  logic RegWrite_s4;
  logic [1:0] DMtoReg_s4;
  logic [4:0] rd_s4;

  ////// stage 4
  logic bra_s4;

  // pipeline MEM/WB
  logic [31:0] se_imm_s5, alu_result_s5, DM_out_s5, pc4_s5;
  logic [1:0] DMtoReg_s5;
  logic RegWrite_s5;
  logic [31:0] wb_data_s5;
  logic [4:0] rd_s5;

  // ##################################################
  // ################## s1: IF stage ##################
  // ##################################################
  wire flush = pcsrc;
  // PS
  wire [IM_adSize-1:0] pc4 =(rst == 1'b1)? 32'b10000000:  IM_address + 3'b100;
  always_comb begin // pc stall
    pc_stall = stall || hazard_stall;
  end // pc stall
  always_ff @(posedge clk)
  begin
    if(rst == 1'b1)
      IM_address <= 32'h10000000;
    else
    begin
      if(pcsrc == 1'b1)         //branch
        IM_address <= IM_addr_s4;  
      else if (pc_stall == 1'b1)
        IM_address <= IM_address;
      else  
        IM_address <= pc4;      
    end
  end 

  // IM is in the testbench file
  assign IM_enable = 1'b1;


  // pipe line IF/ID
  always_comb begin // IF/ID stall
    s12_stall = stall || hazard_stall;
  end // IF/ID stall
  always_comb begin // IM data
    if (rst) begin
      inst_s2 = 32'b0;  
    end
    else if (flush) begin
      inst_s2 = `NOP;
    end
    else if (s12_stall) begin
      inst_s2 = inst_s2;
    end
    else begin
      inst_s2 = IM_out;
    end
  end // IM data
  always_ff @(posedge clk)
  begin 
    if(rst == 1'b1)
    begin
      // inst_s2 <= 32'b0;
      pc_s2   <= 32'b0;
      pc4_s2  <= 32'b0;
    end
    else
    begin
      if(flush == 1'b1)
      begin
        // inst_s2 <= `NOP;
        pc_s2   <= IM_address;
        pc4_s2  <= pc4;
      end
      else if (s12_stall == 1'b1)
      begin
        // inst_s2 <= inst_s2;
        pc_s2   <= pc_s2;
        pc4_s2  <= pc4_s2;
      end
      else
      begin
        // inst_s2 <= IM_out;
        pc_s2   <= IM_address;
        pc4_s2  <= pc4;
      end
    end
  end
  // ##################################################
  // ################## s2: ID stage ##################
  // ##################################################
  //Docode
  wire [4:0]  rs2   = inst_s2[`rs2];
  wire [4:0]  rs1   = inst_s2[`rs1];
  wire [4:0]  rd    = inst_s2[`rd];
  wire [6:0]  op    = inst_s2[`opcode];
  // R type
  wire [6:0]  func7 = inst_s2[`func7];
  wire [2:0]  func3 = inst_s2[`func3];
  // I type
  wire [11:0] I_imm = inst_s2[`I_imm];  //I type immediate value
  // S type
  wire [11:0] S_imm = { inst_s2[`S_immM], inst_s2[`S_immL] }; //S type immediate value Most part
  // B type
  wire [11:0] B_imm = { inst_s2[`B_imm12], inst_s2[`B_imm11], inst_s2[`B_imm10], inst_s2[`B_imm4] };
  // U type
  wire [19:0] U_imm = inst_s2[`U_imm];
  // J type
  wire [19:0] J_imm = { inst_s2[`J_imm20], inst_s2[`J_imm19], inst_s2[`J_imm11], inst_s2[`J_imm10] };
  
  //Control
  control control1 ( .ALU_op(ALU_op), .DMtoReg(DMtoReg), .RegWrite(RegWrite), .DM_en(DM_en), .DM_write(DM_wri), .jump(jump), .branch(branch), .auipc(auipc), .ALU_src(ALU_src), .op(op) );
  
  //Reg File
  reg_32x32 RF1 (.OUT_1(rs1_data), .OUT_2(rs2_data), .Write(RegWrite_s5),
            .Read_ADDR_1(rs1), .Read_ADDR_2(rs2), .DIN(wb_data_s5), .Write_ADDR(rd_s5), 
            .enable(1'b1), .clk(clk), .rst(rst) );

  //Sign Extend

  sign_extend se ( .se_imm(se_imm), .I_imm(I_imm), .S_imm(S_imm), .B_imm(B_imm), .U_imm(U_imm), .J_imm(J_imm), .op(op) );
  
  //hazard unit
  hazard hazard_s2 (.op(op_s3), .rs1_s3(rs1_s3), .rs1_s2(rs1), .rs2_s2(rs2), .stall(hazard_stall), .flush_s3(hazard_flush));
  // pipe line ID/EX
  always_comb begin // harzard or flush
    hazard_or_flush = hazard_flush || flush;
  end // harzard or flush

  always_ff @(posedge clk) 
  begin 
    if(rst == 1'b1)
    begin
      // control
      ALU_op_s3   <= 2'b0;
      DMtoReg_s3  <= 2'b0;
      RegWrite_s3 <= 1'b0;
      DM_en_s3    <= 1'b0;
      DM_write_s3 <= 1'b0;
      jump_s3     <= 1'b0;
      branch_s3   <= 1'b0;
      ALU_src_s3  <= 1'b0;
      auipc_s3    <= 1'b0;
      op_s3       <= 7'b0010011;
      // pc
      pc_s3       <= 32'b0;
      pc4_s3      <= 32'b0;
			// register
      rs1_data_s3 <= 32'b0;
      rs2_data_s3 <= 32'b0;
      rs1_s3      <= 5'b0;
      rs2_s3      <= 5'b0;
      // imm
      se_imm_s3   <= 32'b0;
      // ALU
      func3_s3    <= 3'b0;
      func7_s3    <= 7'b0;
      rd_s3       <= 5'b0;
    end
    else
    begin
      if (hazard_or_flush == 1'b1)
      begin
        // control
        ALU_op_s3   <= 2'b0;
        DMtoReg_s3  <= 2'b0;
        RegWrite_s3 <= 1'b0;
        DM_en_s3    <= 1'b0;
        DM_write_s3 <= 1'b0;
        jump_s3     <= 1'b0;
        auipc_s3    <= 1'b0;
        op_s3       <= 7'b0010011;
        // pc
        pc_s3       <= pc_s2;
        pc4_s3      <= pc4_s2;
        // register
        rs1_data_s3 <= rs1_data;
        rs2_data_s3 <= rs2_data;
        rs1_s3      <= 5'b0;
        rs2_s3      <= 5'b0;
        // imm
        se_imm_s3   <= se_imm;
        // ALU
        func3_s3    <= func3;
        func7_s3    <= func7;
        rd_s3       <= rd;
      end
      else if (stall == 1'b1)
      begin
        // control
        ALU_op_s3   <= ALU_op_s3   ;
        DMtoReg_s3  <= DMtoReg_s3  ;
        RegWrite_s3 <= RegWrite_s3 ;
        DM_en_s3    <= DM_en_s3    ;
        DM_write_s3 <= DM_write_s3 ;
        jump_s3     <= jump_s3     ;
        branch_s3   <= branch_s3   ;
        ALU_src_s3  <= ALU_src_s3  ;
        auipc_s3    <= auipc_s3;
        op_s3       <= op_s3;
        // pc
        pc_s3       <= pc_s3;
        pc4_s3      <= pc4_s3;
        // register
        rs1_data_s3 <= rs1_data_s3;
        rs2_data_s3 <= rs2_data_s3;
        rs1_s3      <= rs1_s3;
        rs2_s3      <= rs2_s3;
        // imm
        se_imm_s3   <= se_imm_s3;
        // ALU
        func3_s3    <= func3_s3;
        func7_s3    <= func7_s3;
        rd_s3       <= rd_s3;
      end
      else
      begin
        // WB
        DMtoReg_s3  <= DMtoReg;
        RegWrite_s3 <= RegWrite;
        rd_s3       <= rd;
        // MEM
        DM_en_s3    <= DM_en;
        DM_write_s3 <= DM_wri;
        jump_s3     <= jump;
        branch_s3   <= branch;
        // EX
        ALU_op_s3   <= ALU_op;
        ALU_src_s3  <= ALU_src;
        auipc_s3    <= auipc;
        op_s3       <= op;
        // pc
        pc_s3       <= pc_s2;
        pc4_s3      <= pc4_s2;
        // register
        rs1_data_s3 <= rs1_data;
        rs2_data_s3 <= rs2_data;
        rs1_s3      <= rs1;
        rs2_s3      <= rs2;
        // imm
        se_imm_s3   <= se_imm;
        // ALU
        func3_s3    <= func3;
        func7_s3    <= func7;
      end  
    end
  end  
  // ##################################################
  // ################## EX stage ######################
  // ##################################################
  assign imm_IM_addr = pc_s3 + {se_imm_s3[31:2], 2'b0 };
  // assign imm_IM_addr = pc_s3 + se_imm_s3;

  
  // forwarding control
  forwarding f (.op(op_s3), .regWrite_s5(RegWrite_s5), .regWrite_s4(RegWrite_s4), .rd_s5(rd_s5), .rd_s4(rd_s4), .src1(rs1_s3), .src2(rs2_s3), .forward1(forward1), .forward2(forward2));

  mux4to1 s4_forward1 ( .Y(data1_s4), .S(DMtoReg_s4), .I0(se_imm_s4), .I1(pc4_s4), .I2(alu_result_s4), .I3(DM_out));
  mux4to1 s5_forward2 ( .Y(data2_s4), .S(DMtoReg_s4), .I0(se_imm_s4), .I1(pc4_s4), .I2(alu_result_s4), .I3(DM_out));

  mux4to1 src1_sel (.Y(data1_s3), .I0(rs1_data_s3), .I1(wb_data_s5), .I2(data1_s4), .I3(32'b0), .S(forward1));
  mux4to1 src2_sel (.Y(data2_s3), .I0(rs2_data_s3), .I1(wb_data_s5), .I2(data2_s4), .I3(32'b0), .S(forward2));
  // assert (forward1 == 2'b11) else $error("forwarding error");

  // alu control
  alu_control alu_ctrl ( .alu_func(alu_func), .ALU_op(ALU_op_s3), .func3(func3_s3), .func7(func7_s3) );
  
  // alu_src_control
  mux2to1 reg1_auipc ( .Y(alu_src1), .I0(data1_s3), .I1(pc_s3), .S(auipc_s3));
  mux2to1 reg0_imm1 ( .Y(alu_src2), .I0(data2_s3), .I1(se_imm_s3), .S(ALU_src_s3) ); 


  // alu
  //logic alu_Overflow;
  ALU ALU1 (.alu_result(alu_result), .Overflow(), .src1(alu_src1), .src2(alu_src2), .enable(1'b1), .OP(alu_func) );

  // alu branch
  xor alu_out(branch_xor, alu_result[0], func3_s3[0] );
  // xor alu_out(branch_xor, alu_result[0], func3_s3[0] );

  // pipe line EX/MEM
  always_ff @(posedge clk) 
  begin
    if(rst == 1'b1)
    begin
      // wb
      RegWrite_s4   <= 1'b0;
      DMtoReg_s4    <= 2'b0;
      // mem
      DM_en_s4      <= 1'b0;
      DM_write_s4   <= 1'b0;
      jump_s4       <= 1'b0;
      branch_s4     <= 1'b0;
      // pc
      pc4_s4        <= 32'b0;
      // branch
      branch_xor_s4 <= 1'b0;
      IM_addr_s4    <= 32'b0;
      // imm
      se_imm_s4     <= 32'b0;
      // reg
      rs2_data_s4   <= 32'b0;
      rd_s4         <= 5'b0;
      alu_result_s4 <= 32'b0;
    end
    else
    begin
      if (flush == 1'b1)
      begin
        // wb
        RegWrite_s4   <= RegWrite_s3;
        DMtoReg_s4    <= DMtoReg_s3;
        // mem
        DM_en_s4      <= DM_en_s3;
        DM_write_s4   <= DM_write_s3;
        jump_s4       <= 1'b0;
        branch_s4     <= 1'b0;
        // pc
        pc4_s4        <= pc4_s3;
        // branch
        branch_xor_s4 <= branch_xor;
        IM_addr_s4    <= imm_IM_addr;
        // imm
        se_imm_s4     <= se_imm_s3;
        // reg
        rs2_data_s4   <= rs2_data_s3;
        rd_s4         <= rd_s3;
        alu_result_s4 <= alu_result;
      end
      else if (stall == 1'b1)
      begin
        // wb
        RegWrite_s4   <= RegWrite_s4;
        DMtoReg_s4    <= DMtoReg_s4;
        // mem
        DM_en_s4      <= DM_en_s4;
        DM_write_s4   <= DM_write_s4;
        jump_s4       <= jump_s4;
        branch_s4     <= branch_s4;
        // pc
        pc4_s4        <= pc4_s4;
        // branch
        branch_xor_s4 <= branch_xor_s4;
        IM_addr_s4    <= IM_addr_s4;
        // imm
        se_imm_s4     <= se_imm_s4;
        // reg
        rs2_data_s4   <= rs2_data_s4;
        rd_s4         <= rd_s4;
        alu_result_s4 <= alu_result_s4;
      end
      else
      begin
        // wb
        RegWrite_s4   <= RegWrite_s3;
        DMtoReg_s4    <= DMtoReg_s3;
        // mem
        DM_en_s4      <= DM_en_s3;
        DM_write_s4   <= DM_write_s3;
        jump_s4       <= jump_s3;
        branch_s4     <= branch_s3;
        // pc
        pc4_s4        <= pc4_s3;
        // branch
        branch_xor_s4 <= branch_xor;
        IM_addr_s4    <= imm_IM_addr;
        // imm
        se_imm_s4     <= se_imm_s3;
        // reg
        rs2_data_s4   <= rs2_data_s3;
        rd_s4         <= rd_s3;
        alu_result_s4 <= alu_result;
      end 
    end
  end  
  // ##################################################
  // ################## MEM stage #####################
  // ##################################################
  and branch_and(bra_s4, branch_s4, branch_xor_s4);

  xor pc_back(pcsrc, jump_s4, bra_s4);

  // DM is in the testbranch
  assign DM_address = alu_result_s4;
  assign DM_in = rs2_data_s4;
  assign DM_write = DM_write_s4;
  assign DM_enable = DM_en_s4;
  
  always_comb begin // DM
    if (rst) begin
      DM_out_s5 = 32'b0;
    end
    else if (flush) begin
      DM_out_s5 = DM_out;
    end
    else if (stall) begin
      DM_out_s5 = DM_out;
    end
    else begin
      DM_out_s5 = DM_out;
    end
  end // DM
  always_ff @(posedge clk) 
  begin
    if (rst == 1'b1)
    begin
      // wb
      RegWrite_s5   <= 1'b0;
      DMtoReg_s5    <= 2'b0;
      // DM
      // DM_out_s5     <= 32'b0;
      alu_result_s5 <= 32'b0;
      pc4_s5        <= 32'b0;
      se_imm_s5     <= 32'b0;
      // rd
      rd_s5         <= 5'b0;
    end
    else
    begin
      if (flush == 1'b1)
      begin
        // wb
        RegWrite_s5   <= RegWrite_s4;
        DMtoReg_s5    <= DMtoReg_s4;
        // DM
        // DM_out_s5     <= DM_out;
        alu_result_s5 <= alu_result_s4;
        pc4_s5        <= pc4_s4;
        se_imm_s5     <= se_imm_s4;
        // rd
        rd_s5         <= rd_s4;
      end
      if (stall == 1'b1)
      begin
        // wb
        RegWrite_s5   <= RegWrite_s5;
        DMtoReg_s5    <= DMtoReg_s5;
        // DM
        // DM_out_s5     <= DM_out_s5;
        alu_result_s5 <= alu_result_s5;
        pc4_s5        <= pc4_s5;
        se_imm_s5     <= se_imm_s5;
        // rd
        rd_s5         <= rd_s5;
      end
      else
      begin
        // wb
        RegWrite_s5   <= RegWrite_s4;
        DMtoReg_s5    <= DMtoReg_s4;
        // DM
        // DM_out_s5     <= DM_out;
        alu_result_s5 <= alu_result_s4;
        pc4_s5        <= pc4_s4;
        se_imm_s5     <= se_imm_s4;
        // rd
        rd_s5         <= rd_s4;
      end
    end
  end
  

  // ##################################################
  // ################## WB stage ######################
  // ##################################################
  mux4to1 wb_result ( .Y(wb_data_s5), .S(DMtoReg_s5), .I0(se_imm_s5), .I1(pc4_s5), .I2(alu_result_s5), .I3(DM_out_s5));


endmodule
