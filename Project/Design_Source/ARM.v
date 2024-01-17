module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,
    input [31:0] ReadData,

    output MemWrite,
    output [31:0] PC,
    output [31:0] OpResult,
    output [31:0] WriteData
); 
    // ******************************************************
    //              BEGIN: SIGNAL DECLARATIONS

    // Fetch Block:
    wire StallF;

    wire [31:0] PCF, PC_Plus_4F;
    wire [31:0] InstrF;

    // Decode Block:
    wire StallD, FlushD;

    reg [31:0] InstrD;

    wire PCSD;
    wire RegWD;
    wire MemWD;
    wire [1:0] FlagWD;
    wire [1:0] ALUControlD;
    wire MemtoRegD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;
    wire [2:0] RegSrcD;
    wire NoWriteD;
    wire M_StartD;
    wire MCycleOpD;
    wire [3:0] CondD;
    wire [6:0] shControlD;

    wire [3:0]  RA1D, RA2D, WA3D;
    wire [31:0] RD1D, RD2D;
    wire [31:0] PC_Plus_8D;
    wire [23:0] InstrImmD;
    wire [31:0] ExtImmD;

    // Execute Block:
    wire StallE, FlushE;
    wire [1:0] ForwardAE, ForwardBE;

    reg [31:0] InstrE;

    reg PCSE;
    reg RegWE;
    reg MemWE;
    reg [1:0] FlagWE;
    reg [1:0] ALUControlE;
    reg MemtoRegE;
    reg ALUSrcE;
    reg NoWriteE;
    reg M_StartE;
    reg MCycleOpE;
    reg [3:0] CondE;
    reg [6:0] shControlE;

    reg [3:0]  RA1E, RA2E, WA3E;
    reg [31:0] RD1E, RD2E;
    reg [31:0] ExtImmE;
    
    wire PCSrcE;
    wire RegWriteE;
    wire MemWriteE;

    wire [1:0] ShE;
    wire [4:0] Shamt5E;
    wire [31:0] ShInE;
    wire [31:0] ShOutE;
    wire [31:0] SrcAE, SrcBE;

    wire [31:0] ALUResultE;
    wire [3:0] ALUFlagsE;
    wire [31:0] MCycleResultE;
    wire M_BusyE;
    wire M_DoneE;
    wire [31:0] WriteDataE;

    wire [31:0] InstrRE;
    wire RegWriteRE;
    wire MemWriteRE;
    wire MemtoRegRE;
    wire [31:0] WriteDataRE;
    wire [3:0] RA2RE;
    wire [3:0] WA3RE;
    wire [31:0] OpResultRE;

    wire [3:0] WA3R;

    // Memory Block:
    wire FlushM;
    wire ForwardM;

    reg [31:0] InstrM;

    reg RegWriteM;
    reg MemWriteM;
    reg MemtoRegM;

    reg [31:0] OpResultM;
    reg [31:0] WriteDataM;
    reg [3:0] RA2M, WA3M;

    wire [31:0] ReadDataM;

    // Write Back Block:
    reg [31:0] InstrW;

    reg RegWriteW;
    reg MemtoRegW;

    reg [31:0] ReadDataW;
    reg [31:0] OpResultW;
    reg [3:0] WA3W;

    wire [31:0] ResultW;

    //               END: SIGNAL DECLARATIONS
    // ******************************************************
    

    // ======================================================
    //         Fetch: Instruction Fetch and Update PC
    // ====================================================== 

    // PIPLINE 1 
    ProgramCounter PC1 (
        .CLK(CLK),
        .Reset(Reset),
        .PCSrc(PCSrcE),
        .Result(OpResultRE),
        .Stall(StallF),

        .PC(PCF),
        .PC_Plus_4(PC_Plus_4F)
    );

    assign PC = PCF;
    assign InstrF = Instr;

    // PIPLINE 2
    always @(posedge CLK) begin
        if (FlushD) begin
            InstrD <= 32'b0;
        end
        else if (StallD) begin
            InstrD <= InstrD;
        end
        else begin
            InstrD <= InstrF;
        end
    end

    // ======================================================
    //     Decode: Registers Fetch and Instruction Decode
    // ======================================================
    
    Decoder Decoder1(
        .Instr(InstrD),

        .PCS(PCSD),
        .RegW(RegWD),
        .MemW(MemWD),
        .MemtoReg(MemtoRegD),
        .ALUSrc(ALUSrcD),
        .ImmSrc(ImmSrcD),
        .RegSrc(RegSrcD),
        .ALUControl(ALUControlD),
        .FlagW(FlagWD),
        .NoWrite(NoWriteD),
        .M_Start(M_StartD),
        .MCycleOp(MCycleOpD)
    );

    //MC04. Add Datapath
    assign RA1D = RegSrcD[2]? InstrD[11:8]: (RegSrcD[0]? 4'd15: InstrD[19:16]);
    assign RA2D = RegSrcD[1]? InstrD[15:12]: InstrD[3:0];
    assign WA3D = RegSrcD[2]? InstrD[19:16]: InstrD[15:12];
    assign PC_Plus_8D = PC_Plus_4F;
    
    assign CondD = InstrD[31:28];
    assign shControlD = InstrD[11:5];
    
    RegisterFile RF1 (
        .CLK(CLK),
        .WE3(RegWriteW),
        .A1(RA1D),
        .A2(RA2D),
        .A3(WA3W),
        .WD3(ResultW),
        .R15(PC_Plus_8D),

        .RD1(RD1D),
        .RD2(RD2D)
    );
    
    assign InstrImmD = InstrD[23:0];

    Extend Extend1 (
        .ImmSrc(ImmSrcD),
        .InstrImm(InstrImmD),

        .ExtImm(ExtImmD)
    );

    // PIPLINE 3
    always @(posedge CLK) begin
        if (FlushE) begin
            InstrE <= 0;

            PCSE <= 0;
            RegWE <= 0;
            MemWE <= 0;
            FlagWE <= 0;
            ALUControlE <= 0;
            MemtoRegE <= 0;
            ALUSrcE <= 0;
            NoWriteE <= 0;
            M_StartE <= 0;
            MCycleOpE <= 0;

            CondE <= 0;
            shControlE <= 0;

            RA1E <= 0;
            RA2E <= 0;
            WA3E <= 0;
            RD1E <= 0;
            RD2E <= 0;
            ExtImmE <= 0;
        end
        else if (StallE) begin
            InstrE <= InstrE;

            PCSE <= PCSE;
            RegWE <= RegWE;
            MemWE <= MemWE;
            FlagWE <= FlagWE;
            ALUControlE <= ALUControlE;
            MemtoRegE <= MemtoRegE;
            ALUSrcE <= ALUSrcE;
            NoWriteE <= NoWriteE;
            M_StartE <= M_StartE;
            MCycleOpE <= MCycleOpE;

            CondE <= CondE;
            shControlE <= shControlE;

            RA1E <= RA1E;
            RA2E <= RA2E;
            WA3E <= WA3E;
            RD1E <= RD1E;
            RD2E <= RD2E;
            ExtImmE <= ExtImmE;
        end
        else begin
            InstrE <= InstrD;

            PCSE <= PCSD;
            RegWE <= RegWD;
            MemWE <= MemWD;
            FlagWE <= FlagWD;
            ALUControlE <= ALUControlD;
            MemtoRegE <= MemtoRegD;
            ALUSrcE <= ALUSrcD;
            NoWriteE <= NoWriteD;
            M_StartE <= M_StartD;
            MCycleOpE <= MCycleOpD;

            CondE <= CondD;
            shControlE <= shControlD;

            RA1E <= RA1D;
            RA2E <= RA2D;
            WA3E <= WA3D;
            RD1E <= RD1D;
            RD2E <= RD2D;
            ExtImmE <= ExtImmD;
        end
    end

    // ======================================================
    //   Execute: Execute DP Type; Calculate Memory Address
    // ======================================================
    CondLogic CondLogic1(
        .CLK(CLK),
        .PCS(PCSE),
        .RegW(RegWE),
        .MemW(MemWE),
        .NoWrite(NoWriteE),
        .FlagW(FlagWE),
        .Cond(CondE),
        .ALUFlags(ALUFlagsE),

        .PCSrc(PCSrcE),
        .RegWrite(RegWriteE),
        .MemWrite(MemWriteE)
    );

    assign ShE = shControlE[1:0];
    assign Shamt5E = shControlE[6:2];
    assign ShInE = ForwardBE[1]? OpResultM: (ForwardBE[0]? ResultW: RD2E);
    assign WriteDataE = ShInE;

    Shifter Shifter1(
        .Sh(ShE),
        .Shamt5(Shamt5E),
        .ShIn(ShInE),

        .ShOut(ShOutE)
    );

    assign SrcAE = ForwardAE[1]? OpResultM: (ForwardAE[0]? ResultW: RD1E);
    assign SrcBE = ALUSrcE? ExtImmE: ShOutE;

    ALU ALU1 (
        .Src_A(SrcAE),
        .Src_B(SrcBE),
        .ALUControl(ALUControlE),

        .ALUResult(ALUResultE),
        .ALUFlags(ALUFlagsE)
    );

    // USE MCycle or FPUnit
    MCycle MCycle1 (
        .CLK(CLK),
        .RESET(Reset),
        .Start(M_StartE),
        .MCycleOp(MCycleOpE),
        .Operand1(SrcAE),
        .Operand2(WriteDataE),

        .Result(MCycleResultE),
        .Busy(M_BusyE),
        .Done(M_DoneE)
    );
/*
    FPUnit FPUnit1 (
        .CLK(CLK),
        .RESET(Reset),
        .FP_Start(M_StartE),
        .FPUnitOp(MCycleOpE),
        .FP_Operand1_in(SrcAE),
        .FP_Operand2_in(WriteDataE),

        .Result(MCycleResultE),
        .FP_Busy(M_BusyE),
        .FP_Done(M_DoneE)
    );
*/
    MCycleReg MCycleReg1 (
        .CLK(CLK),
        
        .M_StartE(M_StartE),
        .M_DoneE(M_DoneE),

        .InstrE(InstrE),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .MemtoRegE(MemtoRegE),
        .WriteDataE(WriteDataE),
        .RA2E(RA2E),
        .WA3E(WA3E),

        .MCycleResultE(MCycleResultE),
        .ALUResultE(ALUResultE),

        .InstrRE(InstrRE),
        .RegWriteRE(RegWriteRE),
        .MemWriteRE(MemWriteRE),
        .MemtoRegRE(MemtoRegRE),
        .WriteDataRE(WriteDataRE),
        .RA2RE(RA2RE),
        .WA3RE(WA3RE),
        .OpResultRE(OpResultRE),

        .WA3R(WA3R)
    );

    // PIPLINE 4
    always @(posedge CLK) begin
        if (FlushM) begin
            InstrM <= 0;

            RegWriteM <= 0;
            MemWriteM <= 0;
            MemtoRegM <= 0;
            OpResultM <= 0;
            WriteDataM <= 0;
            RA2M <= 0;
            WA3M <= 0;
        end
        else begin
            InstrM <= InstrRE;

            RegWriteM <= RegWriteRE;
            MemWriteM <= MemWriteRE;
            MemtoRegM <= MemtoRegRE;
            OpResultM <= OpResultRE;
            WriteDataM <= WriteDataRE;
            RA2M <= RA2RE;
            WA3M <= WA3RE;
        end
    end

    // ======================================================
    //    Mem: Read/write the data from/to the Data Memory
    // ======================================================
    assign MemWrite = MemWriteM;
    assign OpResult = OpResultM;
    assign WriteData = ForwardM? ResultW: WriteDataM;
    assign ReadDataM = ReadData;

    // PIPLINE 5
    always @(posedge CLK) begin
        InstrW <= InstrM;

        RegWriteW <= RegWriteM;
        MemtoRegW <= MemtoRegM;
        ReadDataW <= ReadDataM;
        OpResultW <= OpResultM;
        WA3W <= WA3M;
    end

    // ======================================================
    //    WB: Write the result data into the register file
    // ======================================================

    assign ResultW = MemtoRegW? ReadDataW: OpResultW;

    HazardUnit HazardUnit1 (
        .RA1D(RA1D),
        .RA2D(RA2D),
        .WA3D(WA3D),
        .MemWD(MemWD),
        .M_StartD(M_StartD),
        .RA1E(RA1E),
        .RA2E(RA2E),
        .WA3E(WA3E),
        .WA3R(WA3R),
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .PCSrcE(PCSrcE),
        .M_StartE(M_StartE),
        .M_BusyE(M_BusyE),
        .M_DoneE(M_DoneE),
        .WA3M(WA3M),
        .RegWriteM(RegWriteM),
        .RA2M(RA2M),
        .MemWriteM(MemWriteM),
        .WA3W(WA3W),
        .MemtoRegW(MemtoRegW),
        .RegWriteW(RegWriteW),

        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .StallE(StallE),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .FlushM(FlushM),
        .ForwardM(ForwardM)
    );

endmodule