module Decoder(
    input [31:0] Instr,
	
    output PCS,
    output reg RegW, 
    output reg MemW, 
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg [2:0] RegSrc,
    output reg [2:0] ALUControl,
    output reg [1:0] FlagW,
    output reg NoWrite,
    output reg M_Start,
    output reg MCycleOp,
    output reg Carry_used,
    output reg Reverse_B,
    output reg Reverse_Src    
); 
    reg [1:0] ALUOp;
    reg [1:0] MCOp;
    reg Branch;

    wire [3:0] Rd;
    wire [1:0] Op;
    wire [5:0] Funct;
    wire [1:0] ExInstr;// 00: not ExInstr, 01: MULTIPLY, 10: DIVIDE

    assign Rd = Instr[15:12];
    assign Op = Instr[27:26];
    assign Funct = Instr[25:20];
    assign ExInstr[0] = Instr[25:21] == 5'b00000  && Instr[7:4] == 4'b1001;
    assign ExInstr[1] = Instr[25:20] == 6'b111111 && Instr[7:4] == 4'b1111;
    
    // ================================
    //           Main Decoder
    // ================================

    // *************************************************
    //                negOffset: Set ALUop
    // *************************************************

    // MC02. Add ExInstr MCOp signal, extend RegSrc
    always @(*) begin
        casex({Op,ExInstr,Funct[5],Funct[3],Funct[0]})
            // DP reg
            7'b00_00_0xx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_0_0_00_1_000_11_00; 
            // DP imm
            7'b00_00_1xx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_0_1_00_1_000_11_00;
            // STR posImm
            7'b01_00_x10: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_1_1_01_0_010_00_00;
            // STR negImm
            7'b01_00_x00: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_1_1_01_0_010_01_00;
            // LDR posImm
            7'b01_00_x11: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_1_0_1_01_1_000_00_00;
            // LDR negImm
            7'b01_00_x01: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_1_0_1_01_1_000_01_00;
            // Branch
            7'b10_00_xxx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b1_0_0_1_10_0_001_00_00;
            // ExInstr MUL
            7'b00_01_xxx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_0_0_00_1_100_00_01;
            // ExInstr DIV
            7'b01_10_xxx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_0_0_00_1_100_00_10;

            default:      {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp,MCOp} = 14'b0_0_0_0_00_0_000_00_00;
        endcase
    end

    // ================================
    //            ALU Decoder
    // ================================

    // *************************************************
    //   negOffset: Set ALUConrtol & CMP/N: add NoWrite
    // *************************************************
    always @(*) begin
        casex({ALUOp[1:0],Funct[4:0]})
            //NOT DP instruction
            7'b00_xxxx_x: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_00_0_0_0_0;
            7'b01_xxxx_x: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_00_0_0_0_0;

            // DP instruction
            // And
            7'b11_0000_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b010_00_0_0_0_0;
            7'b11_0000_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b010_10_0_0_0_0;   
            // EOR
            7'b11_0001_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b100_00_0_0_0_0;
            7'b11_0001_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b100_10_0_0_0_0;   
            // SUB
            7'b11_0010_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_00_0_0_0_0;
            7'b11_0010_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_11_0_0_0_0;   
            // RSB
            7'b11_0011_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_00_0_0_0_1;
            7'b11_0011_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_11_0_0_0_1;   
            // ADD
            7'b11_0100_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_00_0_0_0_0;
            7'b11_0100_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_11_0_0_0_0;   
            // ADC
            7'b11_0101_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_00_0_1_0_0;
            7'b11_0101_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_11_0_1_0_0;   
            // SBC
            7'b11_0110_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_00_0_1_0_0;
            7'b11_0110_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_11_0_1_0_0;   
            // RSC
            7'b11_0111_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_00_0_1_0_1;
            7'b11_0111_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_11_0_1_0_1;   
            // TST(S always be 1)
            7'b11_1000_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b010_10_1_0_0_0;   
            // TEQ(S always be 1)
            7'b11_1001_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b100_10_1_0_0_0;  
            // CMP(S always be 1)
            7'b11_1010_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b001_11_1_0_0_0;   
            // CMN(S always be 1)
            7'b11_1011_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_11_1_0_0_0;   
            // ORR
            7'b11_1100_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b011_00_0_0_0_0;
            7'b11_1100_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b011_10_0_0_0_0;   
            // MOV
            7'b11_1101_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b101_00_0_0_0_0;
            7'b11_1101_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b101_10_0_0_0_0;   
            // BIC
            7'b11_1110_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b010_00_0_0_1_0;
            7'b11_1110_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b010_10_0_0_1_0;   
            // MVN
            7'b11_1111_0: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b101_00_0_0_1_0;
            7'b11_1111_1: {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b101_10_0_0_1_0;   
            default:    {ALUControl, FlagW, NoWrite, Carry_used, Reverse_B, Reverse_Src} = 9'b000_00_0_0_0_0;
        endcase
    end

    // MC03. Add MCycle Decoder
    // ================================
    //         MCycle Decoder
    // ================================
    always @(*) begin
        casex(MCOp)
            // No MCycle
            2'b00: {M_Start,MCycleOp} = 2'b00;
            // MUL
            2'b01: {M_Start,MCycleOp} = 2'b10;
            // DIV
            2'b10: {M_Start,MCycleOp} = 2'b11;

            default: {M_Start,MCycleOp} = 2'b00;
        endcase
    end

    // ================================
    //            PC Logic
    // ================================

    assign PCS = ((Rd == 4'd15) & RegW) | Branch;
   
endmodule