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
    output reg [1:0] FlagW
    ); 
    reg ALUOp; 
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
    always @(*) begin
        casex({Op,Funct[5],Funct[0]})
            4'b000x: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b0000xx1001; 
            4'b001x: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b0001001x01;
            4'b01x0: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b0x11010100;
            4'b01x1: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b0101011x00;
            4'b10xx: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b1001100x10;
            default: {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = 10'b0000000000;
        endcase
    end

    // ================================
    //            ALU Decoder
    // ================================
    always @(*) begin
        casex({ALUOp,Funct[5:0]})
            6'b0xxxxx: {ALUControl,FlagW} = 4'b0000;
            6'b101000: {ALUControl,FlagW} = 4'b0000;
            6'b101001: {ALUControl,FlagW} = 4'b0011;
            6'b100100: {ALUControl,FlagW} = 4'b0100;
            6'b100101: {ALUControl,FlagW} = 4'b0111;
            6'b100000: {ALUControl,FlagW} = 4'b1000;
            6'b100001: {ALUControl,FlagW} = 4'b1010;
            6'b111000: {ALUControl,FlagW} = 4'b1100;
            6'b111001: {ALUControl,FlagW} = 4'b1110;
            default:   {ALUControl,FlagW} = 4'b0000;
        endcase
    end

    // ================================
    //            PC Logic
    // ================================

    assign PCS = ((Rd == 4'd15) & RegW) | Branch;
   
endmodule