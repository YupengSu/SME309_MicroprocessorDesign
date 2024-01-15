`timescale 1ns / 1ps

module tb_FPUnit ();
    localparam width = 32;
    localparam period = 2;
    reg              CLK;
    reg              RESET;
    reg              Start;
    reg              MCycleOp;
    reg  [width-1:0] Operand1;
    reg  [width-1:0] Operand2;
    wire [width-1:0] Result;
    wire             Busy;
    wire             Done;

    reg [31:0] index;

    initial begin
        CLK = 1'b0;
        forever #(period / 2) CLK = ~CLK;
    end

    initial begin
        RESET    = 1'b1;
        index = 0;
        Operand1 = 32'h42400000; // * 0 10000100 1...    1.1  * 2^5
        Operand2 = 32'h40A00000; // * 0 10000001 01..    1.01 * 2^2
        Start    = 1'b0;
        MCycleOp = 1'b0;
        #10 RESET = 1'b0;
        #2 Start = 1'b1;
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1  = 32'hC2400000; // * 1 10000100 1...    -1.1  * 2^5
            Operand2  = 32'hC0A00000; // * 1 10000001 01..    -1.01 * 2^2
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h42C80000; // * 100
            Operand2 = 32'h43480000; // * 200
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'hBF000000; // * -0.5
            Operand2 = 32'h3F99999A; // * 1.2
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h1EA2281D; // * 1.7169007646178E−20
            Operand2 = 32'h9FFFFFF5; // * −1.0842014616272E−19
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h10A0201D; // * 6.3158350761658E−29
            Operand2 = 32'h1FFFFFF5; // * 1.0842014616272E−19
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h00000000; // * 0
            Operand2 = 32'h4248CCCC; // * 50.2
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h00800010; 
            Operand2 = 32'h80800001; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h7F7FFFFF; 
            Operand2 = 32'h7F7FFFFF; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h7F800000; 
            Operand2 = 32'h1FFFFFF0; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h7F800000; 
            Operand2 = 32'h00000003; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin: NaN0
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h7F800003; 
            Operand2 = 32'h7F800004; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin: NaN1
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h00000003; 
            Operand2 = 32'h7F800004; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h00000003; 
            Operand2 = 32'h00000005; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 begin
            index = index + 1;
            Start    = 1'b1;
            MCycleOp = 1'b0;
            Operand1 = 32'h00000003; 
            Operand2 = 32'h00800002; 
        end
        #2 Start = 1'b0;
        #100 begin
            Start    = 1'b1;
            MCycleOp = 1'b1;
        end
        #2 Start = 1'b0;

        #100 $finish;
    end

    FPUnit #(
        .width(width)
    ) u_FPUnit (
        .CLK        (CLK),
        .RESET      (RESET),
        .FP_Start   (Start),
        .FPUnitOp   (MCycleOp),
        .FP_Operand1_in(Operand1),
        .FP_Operand2_in(Operand2),
        .Result     (Result),
        .FP_Busy    (Busy),
        .FP_Done    (Done)
    );


endmodule
