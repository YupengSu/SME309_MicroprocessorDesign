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

    // 实例化模块
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
        .MemWriteFinish(MemWriteFinish)
    );

    // 时钟生成
    always begin
        #5 CLK = ~CLK;
    end

    // 测试序列
    initial begin
        // 初始化
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

        // 测试读取
        Start = 1;
        RWAddr = 32'h00000000;
        #10;
        Start = 0;

        // 测试写入
        Start = 1;
        WriteEnable = 1;
        RWAddr = 32'h00000004;
        WriteData = 32'h12345678;
        #10;
        Start = 0;
        WriteEnable = 0;

        // 测试读取写入的数据
        Start = 1;
        RWAddr = 32'h00000004;
        #10;
        Start = 0;

        // 结束测试
        $finish;
    end
endmodule