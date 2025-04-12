module ALU_Control(
    input [1:0] ALUOp,        // ALU operation select signal
    input [5:0] funct,        // Function code for R-type instructions
    output reg [3:0] ALUControl // ALU operation control signal
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010; // ADD for lw and sw
            2'b01: ALUControl = 4'b0110; // SUB for beq
            2'b10: begin
                // R-type instructions: Use the funct field to decide the ALU operation
                case (funct)
                    6'b100000: ALUControl = 4'b0010; // ADD
                    6'b100010: ALUControl = 4'b0110; // SUB
                    6'b100100: ALUControl = 4'b0000; // AND
                    6'b100101: ALUControl = 4'b0001; // OR
                    6'b101010: ALUControl = 4'b0111; // SLT (Set on Less Than)
                    default: ALUControl = 4'b1111; // NOP (no operation)
                endcase
            end
            default: ALUControl = 4'b1111; // NOP (no operation) for unknown ALUOp
        endcase
    end

endmodule