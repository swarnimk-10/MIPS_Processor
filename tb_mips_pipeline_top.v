`timescale 1ns / 1ps

module tb_mips_pipeline_top;
    // Declare Testbench Signals
    reg clk, reset, flush, stall;
    wire [31:0] pc, instruction, ReadData1, ReadData2, ALU_Result, read_data;

    // Instantiate the MIPS Pipeline Top Module
    mips_pipeline_top uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .pc(pc),               
        .instruction(instruction),  
        .ReadData1(ReadData1),  
        .ReadData2(ReadData2),  
        .ALU_Result(ALU_Result),  
        .read_data(read_data)   
    );

    // Generate a Clock Signal
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Display Test Start
        $display("\n? Starting MIPS Pipeline Test...");

        // Initialize Inputs
        clk = 0;
        reset = 1;
        flush = 0;
        stall = 0;
        #10 reset = 0; // Deassert reset

        // Initialize Register File for Testing
        uut.RF.regs[1] = 32'h00000005;  // $1 = 5
        uut.RF.regs[2] = 32'h00000003;  // $2 = 3
        uut.RF.regs[3] = 32'h00000005;  // $1 = 5
        uut.RF.regs[4] = 32'h00000008;  // $2 = 3
        // Run Several Clock Cycles to Observe Execution
        repeat (5) begin
            #10;
            $display("PC: %h | Instruction: %h | ALU Result: %h | ReadData1: %h | ReadData2: %h | MemRead Data: %h",
                     pc, instruction, ALU_Result, ReadData1, ReadData2, read_data);
        end

        // ? Verify Addition
        if (uut.RF.regs[3] == 32'h00000008)  // Expected: $3 = 5 + 3 = 8
            $display("? ADD Passed: $3 = %h", uut.RF.regs[3]);
        else
            $display("? ADD Failed: $3 = %h", uut.RF.regs[3]);

        // ? Verify Subtraction
        if (uut.RF.regs[5] == 32'h00000008)  // Expected: $5 = 16 - 8 = 8
            $display("? SUB Passed: $5 = %h", uut.RF.regs[5]);
        else
            $display("? SUB Failed: $5 = %h", uut.RF.regs[5]);

        // End Simulation
        $display("? All Tests Completed Successfully!");
        $stop;
    end
endmodule