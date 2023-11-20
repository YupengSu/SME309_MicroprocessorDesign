    module Decoder(
    input [31:0] Instr,
	
    output PCS,
    output reg RegW, 
    output reg MemW, 
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg [1:0] RegSrc,
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW,
    output reg NoWrite
    ); 
    reg [1:0] ALUOp; 
    reg Branch;

    wire [3:0] Rd;
    wire [1:0] Op;
    wire [5:0] Funct;

    assign Rd = Instr[15:12];
    assign Op = Instr[27:26];
    assign Funct = Instr[25:20];
    
    // ================================
    //           Main Decoder
    // ================================

    // *************************************************
    //                negOffset: Set ALUop
    // *************************************************
    always @(*) begin
        casex({Op,Funct[5],Funct[3],Funct[0]})
            // DP reg
            5'b000xx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0000xx10011; 
            // DP imm
            5'b001xx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0001001x011;
            // STR posImm
            5'b01x10: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0x110101000;
            // STR negImm
            5'b01x00: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0x110101001;
            // LDR posImm
            5'b01x11: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0101011x000;
            // LDR negImm
            5'b01x01: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b0101011x001;
            // Branch
            5'b10xxx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b1001100x100;

            default:  {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 11'b00000000000;
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
            // Not DP
            7'b00xxxxx: {ALUControl,FlagW,NoWrite} = 5'b00000; // Pos Offset
            7'b01xxxxx: {ALUControl,FlagW,NoWrite} = 5'b01000; // Neg Offset
            // DP
            7'b1101000: {ALUControl,FlagW,NoWrite} = 5'b00000;
            7'b1101001: {ALUControl,FlagW,NoWrite} = 5'b00110;
            7'b1100100: {ALUControl,FlagW,NoWrite} = 5'b01000;
            7'b1100101: {ALUControl,FlagW,NoWrite} = 5'b01110;
            7'b1100000: {ALUControl,FlagW,NoWrite} = 5'b10000;
            7'b1100001: {ALUControl,FlagW,NoWrite} = 5'b10100;
            7'b1111000: {ALUControl,FlagW,NoWrite} = 5'b11000;
            7'b1111001: {ALUControl,FlagW,NoWrite} = 5'b11100;
            // CMP/CMN
            7'b1110101: {ALUControl,FlagW,NoWrite} = 5'b01111;
            7'b1110111: {ALUControl,FlagW,NoWrite} = 5'b00111;
            default:    {ALUControl,FlagW,NoWrite} = 5'b00000;
        endcase
    end

    // ================================
    //            PC Logic
    // ================================

    assign PCS = ((Rd == 4'd15) & RegW) | Branch;
   
endmodule