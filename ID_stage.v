module ID_stage(
    input         clk,
    input         reset,
    input  [31:0] pc_in,
    input  [31:0] instruction,
    input  [31:0] regfile_data1,
    input  [31:0] regfile_data2,
    output reg [31:0] pc_plus4,
    output reg [31:0] out_read_data1,
    output reg [31:0] out_read_data2,
    output reg [31:0] sign_extended,
    output reg [4:0]  rs,
    output reg [4:0]  rt,
    output reg [4:0]  rd,
    // Control signals: note that unsupported instructions default to NOP.
    output reg        RegDst,   // 1 => destination register is rd, 0 => rt.
    output reg        ALUSrc,   // 1 => ALU second operand from immediate.
    output reg [1:0]  ALUOp,    // 00:add; 01:subtract; 10:use R-type funct (simplified below).
    output reg        MemRead,
    output reg        MemWrite,
    output reg        Branch,
    output reg        RegWrite,
    output reg        MemToReg,
    output [5:0]  funct,    // Funct field for R-type instructions
    output [3:0] ALUControl  // ALU Control signal
);

    wire [3:0] alu_control_signal;

    // Instantiate the ALU Control Unit inside ID Stage
    ALU_Control alu_control_inst (
        .ALUOp(ALUOp),
        .funct(funct),
        .ALUControl(alu_control_signal)
    );

    always @(*) begin
        // Compute PC + 4.
        pc_plus4 = pc_in + 4;
        
        // Decode fields from the instruction.
        rs = instruction[25:21];
        rt = instruction[20:16];
        rd = instruction[15:11];
        
        // Pass along the register file data (which was read externally).
        out_read_data1 = regfile_data1;
        out_read_data2 = regfile_data2;
        
        // Sign-extend the 16-bit immediate to 32 bits.
        sign_extended = {{16{instruction[15]}}, instruction[15:0]};
        
        // Generate control signals based on opcode (bits 31:26)
        case (instruction[31:26])
            6'b000000: begin // R-type
                RegDst   = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10; // For R-type, typically use the function field (here simplified).
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                RegWrite = 1'b1;
                MemToReg = 1'b0;
            end
            6'b100011: begin // lw
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00; // Addition for address calculation.
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                RegWrite = 1'b1;
                MemToReg = 1'b1;
            end
            6'b101011: begin // sw
                RegDst   = 1'b0; // Irrelevant.
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00; // Addition for address calculation.
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                Branch   = 1'b0;
                RegWrite = 1'b0;
                MemToReg = 1'b0;
            end
            6'b000100: begin // beq
                RegDst   = 1'b0; // Don't care.
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01; // Subtraction used for comparison.
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;
                RegWrite = 1'b0;
                MemToReg = 1'b0;
            end
            default: begin // For unsupported instructions, all controls are off (NOP).
                RegDst   = 1'b0;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b00;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                RegWrite = 1'b0;
                MemToReg = 1'b0;
            end
        endcase
    end

    // Pass the funct field (bits 5:0) for R-type instructions
    assign funct = instruction[5:0];
    
    // Output ALU control signal to the EX stage
    assign ALUControl = alu_control_signal;
    
endmodule