//=========================================================
// Top-level Module: mips_pipeline_top
// This module instantiates all five stages along with the
// four pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB).
// It also instantiates the register file that is shared by ID and WB.
// The flush and stall inputs are used to clear/hold pipeline registers.
//=========================================================
module mips_pipeline_top (
    input clk,
    input reset,
    input flush,
    input stall,
    output [31:0] pc,          
    output [31:0] instruction,  
    output [31:0] ReadData1,   
    output [31:0] ReadData2,   
    output [31:0] ALU_Result,
    output [31:0] read_data     
);

    // -------------------------------
    // IF Stage Signals & Pipeline Registers
    // -------------------------------
    wire [31:0] if_pc, if_instruction;
    reg  [31:0] IFID_pc, IFID_inst;
    
    // -------------------------------
    // ID Stage Signals & Pipeline Registers
    // -------------------------------
    wire [31:0] id_pc_plus4;
    wire [31:0] id_read_data1, id_read_data2;
    wire [31:0] id_sign_extended;
    wire [4:0]  id_rs, id_rt, id_rd;
    wire        id_RegDst, id_ALUSrc, id_MemRead, id_MemWrite, id_Branch, id_RegWrite, id_MemToReg;
    wire [1:0]  id_ALUOp;
    wire [5:0]  id_funct;
    wire [1:0]  id_ALUControl;
    
    reg  [31:0] IDEX_pc_plus4, IDEX_rdata1, IDEX_rdata2, IDEX_sign_extended;
    reg  [4:0]  IDEX_rs, IDEX_rt, IDEX_rd;
    reg         IDEX_RegDst, IDEX_ALUSrc;
    reg  [1:0]  IDEX_ALUOp;
    reg         IDEX_MemRead, IDEX_MemWrite, IDEX_Branch, IDEX_RegWrite, IDEX_MemToReg;
    reg  [5:0]  IDEX_funct;
    reg  [3:0]  IDEX_ALUControl;
    // -------------------------------
    // EX Stage Signals & Pipeline Registers
    // -------------------------------
    wire [31:0] ex_alu_result, ex_branch_addr;
    wire        ex_zero;
    wire [4:0]  ex_reg_dst;
    
    reg  [31:0] EXMEM_branch_addr, EXMEM_alu_result, EXMEM_rdata2;
    reg         EXMEM_zero;
    reg  [4:0]  EXMEM_reg_dst;
    reg         EXMEM_MemRead, EXMEM_MemWrite, EXMEM_Branch, EXMEM_RegWrite, EXMEM_MemToReg;
    
    // -------------------------------
    // MEM Stage Signals & Pipeline Registers
    // -------------------------------
    wire [31:0] mem_read_data;
    
    reg  [31:0] MEMWB_read_data, MEMWB_alu_result;
    reg  [4:0]  MEMWB_reg_dst;
    reg         MEMWB_RegWrite, MEMWB_MemToReg;
    
    // -------------------------------
    // WB Stage Signals
    // -------------------------------
    wire [31:0] wb_data;
    wire [4:0]  wb_reg;
    wire        wb_RegWrite;
    
    // -------------------------------
    // Register File instance
    // The read addresses come from the IF/ID instruction fields.
    // -------------------------------
    wire [4:0] rf_rs = IFID_inst[25:21];
    wire [4:0] rf_rt = IFID_inst[20:16];
    wire [31:0] rf_read_data1, rf_read_data2;
    
    RegisterFile RF (
        .clk(clk),
        .reset(reset),
        .RegWrite(MEMWB_RegWrite),
        .rs(rf_rs),
        .rt(rf_rt),
        .rd(MEMWB_reg_dst),
        .WriteData(wb_data),
        .ReadData1(rf_read_data1),
        .ReadData2(rf_read_data2)
    );
    
    // -------------------------------
    // Instantiate IF Stage
    // -------------------------------
    IF_stage IF_UNIT (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_out(if_pc),
        .instruction_out(if_instruction)
    );
    
    // -------------------------------
    // IF/ID Pipeline Register
    // -------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            IFID_pc   <= 32'b0;
            IFID_inst <= 32'b0;
        end else if (!stall) begin
            IFID_pc   <= if_pc;
            IFID_inst <= if_instruction;
        end
    end
    
    // -------------------------------
    // Instantiate ID Stage
    // -------------------------------
    ID_stage ID_UNIT (
        .clk(clk),
        .reset(reset),
        .pc_in(IFID_pc),
        .instruction(IFID_inst),
        .regfile_data1(rf_read_data1),
        .regfile_data2(rf_read_data2),
        .pc_plus4(id_pc_plus4),
        .out_read_data1(id_read_data1),
        .out_read_data2(id_read_data2),
        .sign_extended(id_sign_extended),
        .rs(id_rs),
        .rt(id_rt),
        .rd(id_rd),
        .RegDst(id_RegDst),
        .ALUSrc(id_ALUSrc),
        .ALUOp(id_ALUOp),
        .MemRead(id_MemRead),
        .MemWrite(id_MemWrite),
        .Branch(id_Branch),
        .RegWrite(id_RegWrite),
        .MemToReg(id_MemToReg),
        .funct(id_funct),
        .ALUControl(id_ALUControl)
    );
    
    // -------------------------------
    // ID/EX Pipeline Register
    // -------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IDEX_pc_plus4     <= 32'b0;
            IDEX_rdata1       <= 32'b0;
            IDEX_rdata2       <= 32'b0;
            IDEX_sign_extended <= 32'b0;
            IDEX_rs           <= 5'b0;
            IDEX_rt           <= 5'b0;
            IDEX_rd           <= 5'b0;
            IDEX_RegDst       <= 1'b0;
            IDEX_ALUSrc       <= 1'b0;
            IDEX_ALUOp        <= 2'b0;
            IDEX_MemRead      <= 1'b0;
            IDEX_MemWrite     <= 1'b0;
            IDEX_Branch       <= 1'b0;
            IDEX_RegWrite     <= 1'b0;
            IDEX_MemToReg     <= 1'b0;
            IDEX_funct        <= 6'b0;
            IDEX_ALUControl   <= 4'b0;
        end else if (!stall) begin
            IDEX_pc_plus4     <= id_pc_plus4;
            IDEX_rdata1       <= id_read_data1;
            IDEX_rdata2       <= id_read_data2;
            IDEX_sign_extended <= id_sign_extended;
            IDEX_rs           <= id_rs;
            IDEX_rt           <= id_rt;
            IDEX_rd           <= id_rd;
            IDEX_RegDst       <= id_RegDst;
            IDEX_ALUSrc       <= id_ALUSrc;
            IDEX_ALUOp        <= id_ALUOp;
            IDEX_MemRead      <= id_MemRead;
            IDEX_MemWrite     <= id_MemWrite;
            IDEX_Branch       <= id_Branch;
            IDEX_RegWrite     <= id_RegWrite;
            IDEX_MemToReg     <= id_MemToReg;
            IDEX_funct        <= id_funct;
            IDEX_ALUControl   <= id_ALUControl;
        end
    end
    
    // -------------------------------
    // Instantiate EX Stage
    // -------------------------------
    EX_stage EX_UNIT (
        .clk(clk),
        .reset(reset),
        .pc_plus4(IDEX_pc_plus4),
        .read_data1(IDEX_rdata1),
        .read_data2(IDEX_rdata2),
        .sign_extended(IDEX_sign_extended),
        .rs(IDEX_rs),
        .rt(IDEX_rt),
        .rd(IDEX_rd),
        .funct(IDEX_funct),
        .RegDst(IDEX_RegDst),
        .ALUSrc(IDEX_ALUSrc),
        .ALUOp(IDEX_ALUOp),
        .alu_result(ex_alu_result),
        .zero(ex_zero),
        .branch_addr(ex_branch_addr),
        .reg_dst(ex_reg_dst)
    );
    
    // -------------------------------
    // EX/MEM Pipeline Register
    // -------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EXMEM_branch_addr <= 32'b0;
            EXMEM_zero        <= 1'b0;
            EXMEM_alu_result  <= 32'b0;
            EXMEM_rdata2      <= 32'b0;
            EXMEM_reg_dst     <= 5'b0;
            EXMEM_MemRead     <= 1'b0;
            EXMEM_MemWrite    <= 1'b0;
            EXMEM_Branch      <= 1'b0;
            EXMEM_RegWrite    <= 1'b0;
            EXMEM_MemToReg    <= 1'b0;
        end else begin
            EXMEM_branch_addr <= ex_branch_addr;
            EXMEM_zero        <= ex_zero;
            EXMEM_alu_result  <= ex_alu_result;
            EXMEM_rdata2      <= IDEX_rdata2;
            EXMEM_reg_dst     <= ex_reg_dst;
            EXMEM_MemRead     <= IDEX_MemRead;
            EXMEM_MemWrite    <= IDEX_MemWrite;
            EXMEM_Branch      <= IDEX_Branch;
            EXMEM_RegWrite    <= IDEX_RegWrite;
            EXMEM_MemToReg    <= IDEX_MemToReg;
        end
    end
    
    // -------------------------------
    // Instantiate MEM Stage
    // -------------------------------
    MEM_stage MEM_UNIT (
        .clk(clk),
        .reset(reset),
        .branch_addr(EXMEM_branch_addr),
        .zero(EXMEM_zero),
        .alu_result(EXMEM_alu_result),
        .write_data(EXMEM_rdata2),
        .MemRead(EXMEM_MemRead),
        .MemWrite(EXMEM_MemWrite),
        .Branch(EXMEM_Branch),
        .read_data(mem_read_data)
    );
    
    // -------------------------------
    // MEM/WB Pipeline Register
    // -------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEMWB_read_data  <= 32'b0;
            MEMWB_alu_result <= 32'b0;
            MEMWB_reg_dst    <= 5'b0;
            MEMWB_RegWrite   <= 1'b0;
            MEMWB_MemToReg   <= 1'b0;
        end else begin
            MEMWB_read_data  <= mem_read_data;
            MEMWB_alu_result <= EXMEM_alu_result;
            MEMWB_reg_dst    <= EXMEM_reg_dst;
            MEMWB_RegWrite   <= EXMEM_RegWrite;
            MEMWB_MemToReg   <= EXMEM_MemToReg;
        end
    end
    
    // -------------------------------
    // Instantiate WB Stage
    // -------------------------------
    WB_stage WB_UNIT (
        .clk(clk),
        .reset(reset),
        .read_data(MEMWB_read_data),
        .alu_result(MEMWB_alu_result),
        .MemToReg(MEMWB_MemToReg),
        .reg_dst(MEMWB_reg_dst),
        .RegWrite(MEMWB_RegWrite),
        .wb_data(wb_data),
        .wb_reg(wb_reg),
        .wb_RegWrite(wb_RegWrite)
    );
    // Connecting the pipeline registers to the testbench outputs
assign pc = if_pc;             
assign instruction = if_instruction;     
assign ReadData1 = id_read_data1;   
assign ReadData2 = id_read_data2;  
assign ALU_Result = ex_alu_result;  
assign read_data = MEMWB_read_data;  

endmodule