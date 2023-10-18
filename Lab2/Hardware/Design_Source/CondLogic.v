module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input MemW,
    input [1:0] FlagW,
    input [3:0] Cond,
    input [3:0] ALUFlags,
    
    output PCSrc,
    output RegWrite,
    output MemWrite
    ); 
    
    reg CondEx ;
    reg N = 0, Z = 0, C = 0, V = 0 ;
    
endmodule