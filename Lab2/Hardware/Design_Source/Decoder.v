module Decoder(
    input [31:0] Instr,
	
    output PCS,
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW
    ); 
    
    wire ALUOp ; 
    wire Branch ;
   
endmodule