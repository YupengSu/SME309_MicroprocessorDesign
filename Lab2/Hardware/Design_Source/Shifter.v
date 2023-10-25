module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output reg [31:0] ShOut
    );

    always @(*) begin
        case (Sh)
            2'b00: ShOut[31:0] = ShIn[31:0] << Shamt5;
            2'b01: ShOut[31:0] = ShIn[31:0] >> Shamt5;
            2'b10: ShOut[31:0] = ShIn[31:0] >>> Shamt5;
            2'b11: ShOut[31:0] = (ShIn[31:0] >> Shamt5) | (ShIn[31:0] << 32-Shamt5);
        endcase
    end
     
endmodule 
