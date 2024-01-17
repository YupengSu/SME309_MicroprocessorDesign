module ARM (
    input        CLK,
    input        Reset,
    input [31:0] Instr,
    input [31:0] ReadData,

    output [ 1:0] MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
);

    wire MemtoReg, PCSrc, PCSrc_out, ComResult, RegSrc, sign, sign_for_reg;
    wire [31:0] result, PC_next, WD3, PC_Plus_4, ALU_Src_A, ALU_Src_B, RD1, RD2, ExtImm, Com_Src1, Com_Src2;
    wire [1:0] ALUSrc, RegWrite, WE3, ALUControl;
    wire [4:0] A1, A2, A3;
    wire [2:0] ComControl, ImmSrc;

    assign result    = MemtoReg ? ReadData : ALUResult;
    assign PC_next   = result;
    assign PCSrc     = PCSrc_out & ComResult;
    assign WD3       = RegSrc ? PC_Plus_4 : result;
    assign ALU_Src_A = ALUSrc[1] ? RD1 : PC;
    assign ALU_Src_B = ALUSrc[0] ? RD2 : ExtImm;
    assign A1        = Instr[19:15];
    assign A2        = Instr[24:20];
    assign A3        = Instr[11:7];
    assign WE3       = RegWrite;
    assign Com_Src1  = RD1;
    assign Com_Src2  = RD2;
    assign WriteData = RD2;

    ProgramCounter u_ProgramCounter (
        .CLK      (CLK),
        .Reset    (Reset),
        .PCSrc    (PCSrc),
        .PC_next  (PC_next),
        .PC       (PC),
        .PC_Plus_4(PC_Plus_4)
    );

    ALU u_ALU (
        .ALU_Src_A (ALU_Src_A),
        .ALU_Src_B (ALU_Src_B),
        .ALUControl(ALUControl),
        .ALUResult (ALUResult)
    );

    Comparator u_Comparator (
        .Com_Src1  (Com_Src1),
        .Com_Src2  (Com_Src2),
        .ComControl(ComControl),
        .ComResult (ComResult)
    );

    ControlUnit u_ControlUnit (
        .Instr       (Instr),
        .CLK         (CLK),
        .MemtoReg    (MemtoReg),
        .MemWrite    (MemWrite),
        .ALUSrc      (ALUSrc),
        .ImmSrc      (ImmSrc),
        .RegWrite    (RegWrite),
        .ALUControl  (ALUControl),
        .PCSrc_out   (PCSrc_out),
        .RegSrc      (RegSrc),
        .ComControl  (ComControl),
        .sign        (sign),
        .sign_for_reg(sign_for_reg)
    );

    Extend u_Extend (
        .ImmSrc(ImmSrc),
        .Instr (Instr),
        .sign  (sign),
        .ExtImm(ExtImm)
    );

    RegisterFile u_RegisterFile (
        .CLK         (CLK),
        .WE3         (WE3),
        .A1          (A1),
        .A2          (A2),
        .A3          (A3),
        .WD3         (WD3),
        .sign_for_reg(sign_for_reg),
        .RD1         (RD1),
        .RD2         (RD2)
    );



endmodule
