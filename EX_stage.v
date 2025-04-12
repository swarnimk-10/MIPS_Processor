module EX_stage(
    input         clk,
    input         reset,
    input  [31:0] pc_plus4,
    input  [31:0] read_data1,  // Data from register file
    input  [31:0] read_data2,  // Data from register file
    input  [31:0] sign_extended, // Sign-extended immediate value
    input  [4:0]  rs,           // Source register 1
    input  [4:0]  rt,           // Source register 2
    input  [4:0]  rd,           // Destination register
    input         RegDst,       // 1 => destination register is rd, 0 => rt
    input         ALUSrc,       // 1 => ALU second operand is immediate
    input  [1:0]  ALUOp,        // ALU operation select
    input [5:0] funct,
    output reg [31:0] alu_result, // ALU result
    output reg        zero,     // Zero flag
    output reg [31:0] branch_addr, // Branch address
    output reg [4:0]  reg_dst   // Destination register for writing back
);

    wire [3:0] ALUControl;
    wire [31:0] alu_out;  // Wire to capture ALU result
    wire alu_zero;        // Wire to capture ALU zero flag
    reg [31:0] operand2;  // ALU second operand

    // Instantiate ALU Control Unit
    ALU_Control alu_control_inst (
        .ALUOp(ALUOp),
        .funct(funct),
        .ALUControl(ALUControl)
    );

    // ALU Operand selection
    always @(*) begin
        operand2 = (ALUSrc) ? sign_extended : read_data2;
    end

    // Instantiate ALU for computation
    ALU alu_unit (
        .operand1(read_data1),
        .operand2(operand2),
        .ALUControl(ALUControl),
        .result(alu_out),
        .zero(alu_zero)
    );

    // Assign values to reg variables inside always block
    always @(*) begin
        alu_result = alu_out;  // Assign wire output to reg
        zero = alu_zero;       // Assign wire output to reg
        branch_addr = pc_plus4 + (sign_extended << 2); // Compute branch target address
        reg_dst = (RegDst) ? rd : rt;  // Select destination register
    end
    always@(*) begin
        $display("EX Stage: ALUOp = %b, funct = %b, ALUControl = %b", ALUOp, funct, ALUControl);
    end
endmodule
