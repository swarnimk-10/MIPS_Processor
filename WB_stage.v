// WB Stage: Write Back
// Multiplexes the correct data (from memory or ALU) as write data.
//=========================================================
module WB_stage(
    input         clk,
    input         reset,
    input  [31:0] read_data,
    input  [31:0] alu_result,
    input         MemToReg,
    input  [4:0]  reg_dst,
    input         RegWrite,
    output reg [31:0] wb_data,
    output reg [4:0]  wb_reg,
    output reg        wb_RegWrite
);
    always @(*) begin
        // Select memory read data if MemToReg is asserted; otherwise use ALU result.
        wb_data    = (MemToReg) ? read_data : alu_result;
        wb_reg     = reg_dst;
        wb_RegWrite = RegWrite;
    end
endmodule
