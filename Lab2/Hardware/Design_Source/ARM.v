module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,
    input [31:0] ReadData,

    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
); 
    // ================================================
    //                 Program Counter
    // ================================================
    wire PCSrc;
    wire [31:0] Result;
    wire [31:0] PC_Plus_4;
    wire MemtoReg;

    assign Result = MemtoReg? ReadData: ALUResult;

    ProgramCounter PC1 (
        .CLK(CLK),
        .Reset(Reset),
        .PCSrc(PCSrc),
        .Result(Result),
        .PC(PC),
        .PC_Plus_4(PC_Plus_4)
    );

    // ================================================
    //                 Control Unit
    // ================================================
    wire [3:0] ALUFlags;
    wire [1:0] ALUControl;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire RegWrite;
    wire [1:0] RegSrc;

    ControlUnit ControlUnit1 (
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        .CLK(CLK),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .PCSrc(PCSrc)
    );

    // ================================================
    //                 Register File
    // ================================================
    wire [3:0] RA1, RA2, RA3;
    wire [31:0] R15;
    wire [31:0] RD1, RD2;

    assign RA1 = RegSrc[0]? 4'd15: Instr[19:16];
    assign RA2 = RegSrc[1]? Instr[15:12]: Instr[3:0];
    assign RA3 = Instr[15:12];
    assign R15 = PC_Plus_4 + 32'd4;
    assign WriteData = RD2;
    
    RegisterFile RF1 (
        .CLK(CLK),
        .WE3(RegWrite),
        .A1(RA1),
        .A2(RA2),
        .A3(RA3),
        .WD3(Result),
        .R15(R15),
        .RD1(RD1),
        .RD2(RD2)
    );

    // ================================================
    //                     Extend
    // ================================================
    wire [23:0] InstrImm;
    assign InstrImm = Instr[23:0];
    wire [31:0] ExtImm;

    Extend Extend1 (
        .ImmSrc(ImmSrc),
        .InstrImm(InstrImm),
        .ExtImm(ExtImm)
    );

    // ================================================
    //                       ALU
    // ================================================
    wire [31:0] Src_A, Src_B;

    assign Src_A = RD1;
    assign Src_B = ALUSrc? ExtImm: RD2;

    ALU ALU1 (
        .Src_A(Src_A),
        .Src_B(Src_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

endmodule