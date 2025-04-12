// Register File Module
// 32 registers of 32 bits each. Register 0 is hard-wired to 0.
//=========================================================
module RegisterFile(
    input        clk,
    input        reset,
    input        RegWrite,
    input  [4:0] rs,
    input  [4:0] rt,
    input  [4:0] rd,
    input  [31:0] WriteData,
    output reg [31:0] ReadData1,
    output reg [31:0] ReadData2
);
    reg [31:0] regs [31:0];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end
    // Synchronous write; on reset all registers are cleared.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            // Write only if RegWrite is asserted and not writing to register 0.
            if (RegWrite && (rd != 0))
                regs[rd] <= WriteData;
        end
    end
    
    // Asynchronous read.
    always @(*) begin
        ReadData1 = regs[rs];
        ReadData2 = regs[rt];
    end
endmodule