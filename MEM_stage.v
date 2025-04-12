// MEM Stage: Data Memory Access
// Performs data memory read/write operations.
//=========================================================
module MEM_stage(
    input         clk,
    input         reset,
    input  [31:0] branch_addr,
    input         zero,
    input  [31:0] alu_result,
    input  [31:0] write_data,
    input         MemRead,
    input         MemWrite,
    input         Branch,
    output reg [31:0] read_data
);
    // Simple data memory (RAM) with 256 32-bit words.
    reg [31:0] data_memory [0:255];
    integer i;
    
    // Memory write (synchronous) and reset initialize.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 256; i = i + 1)
                data_memory[i] <= 32'b0;
        end else begin
            if (MemWrite)
                data_memory[alu_result[9:2]] <= write_data;
        end
    end
    
    // Memory read is modeled as combinational.
    always @(*) begin
        if (MemRead)
            read_data = data_memory[alu_result[9:2]];
        else
            read_data = 32'b0;
    end
endmodule