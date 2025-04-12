//=========================================================
// IF Stage: Instruction Fetch (PC update & mem read)
//=========================================================
module IF_stage(
    input         clk,
    input         reset,
    input         stall,      // When asserted, the IF stage does not update PC.
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);
    // Simple instruction memory (ROM) with 256 32-bit words.
    reg [31:0] instruction_memory [0:255];
    integer i;
    
    // Initialize instruction memory - for simulation only.
    initial begin
        for (i = 0; i < 256; i = i + 1)
            instruction_memory[i] = 32'b0;
        instruction_memory[0] = 32'b000000_00001_00010_00011_00000_100000;  // ADD $3, $1, $2  (R-type)
        instruction_memory[1] = 32'b000000_00100_00011_00101_00000_100010;  // SUB $5, $4, $3  (R-type)  
    end
    
    // PC update: increments by 4 each clock cycle (if not stalled).
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;
        else if (!stall)
            pc_out <= pc_out + 4;
    end
    
    // Read the instruction from ROM using word addressing.
    always @(*) begin
        // Using pc_out[9:2] to index into 256-word memory.
        instruction_out = instruction_memory[pc_out[9:2]];
    end
endmodule