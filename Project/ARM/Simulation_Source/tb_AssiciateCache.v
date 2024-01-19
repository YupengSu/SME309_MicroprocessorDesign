`timescale 1ns / 1ps

module tb_AssociativeCache;
    reg CLK;
    reg Reset;
    reg Start;
    reg WriteEnable;
    reg [31:0] RWAddr;
    reg [31:0] WriteData;
    wire [31:0] ReadData;
    wire WriteReady;
    wire ReadReady;
    reg MemReadFinish;
    reg MemWriteFinish;
    wire MemReadStart;         
    wire MemWriteStart;          
    wire [31:0] MemReadAddr;    
    reg [31:0] MemReadData;      
    wire [31:0] MemWriteAddr;
    wire [31:0] MemWriteData;

    // 实例化模�?
    AssociativeCache4Way UUT (
        .CLK(CLK),
        .Reset(Reset),
        .Start(Start),
        .WriteEnable(WriteEnable),
        .RWAddr(RWAddr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .WriteReady(WriteReady),
        .ReadReady(ReadReady),
        .MemReadFinish(MemReadFinish),
        .MemWriteFinish(MemWriteFinish),
        .MemReadStart(MemReadStart),
        .MemWriteStart(MemWriteStart),
        .MemReadAddr(MemReadAddr),
        .MemReadData(MemReadData),
        .MemWriteAddr(MemWriteAddr),
        .MemWriteData(MemWriteData)
    );

    reg [31:0] DataMem [0:1024];
    integer i;

    initial begin
        for(i = 0; i < 1024; i = i+1) begin
            if (i % 256 == 0)
                DataMem[i] = 1;
            else
                DataMem[i] = 0;
        end
    end

    always @(*) begin
        MemReadFinish = MemReadStart;
        MemWriteFinish = MemWriteStart;
    end

    always @(*) begin
        if (MemReadStart) begin
            MemReadData = DataMem[MemReadAddr[11:2]];
        end
        else if (MemWriteStart) begin
            DataMem[MemWriteAddr[11:2]] = MemWriteData;
        end
    end

    // 时钟生成
    always begin
        #5 CLK = ~CLK;
    end

    // 测试序列
    initial begin
        // 初始�?
        CLK = 0;
        Reset = 1;
        Start = 0;
        WriteEnable = 0;
        RWAddr = 0;
        WriteData = 0;
        MemReadFinish = 0;
        MemWriteFinish = 0;

        #10;
        Reset = 0;

        // 测试读取(Write Miss)
        Start = 1;
        RWAddr = 32'h00000000;
        #10;
        Start = 0;
        #100;
        Start = 1;
        RWAddr = 32'h00008000;
        #10;
        Start = 0;
        #100;
        Start = 1;
        RWAddr = 32'h00010000;
        #10;
        Start = 0;
        #100;
        // 结束测试
        $finish;
    end
endmodule