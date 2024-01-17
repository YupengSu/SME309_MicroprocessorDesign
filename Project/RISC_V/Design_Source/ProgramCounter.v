module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc, // 0: PC+1  ;  1: PC+imm or rs1+imm
    input [31:0] PC_next,
    
    output reg [31:0] PC,
    output [31:0] PC_Plus_4
); 

//fill your Verilog code here

    assign PC_Plus_4 = PC + 32'd4;

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            PC <= 32'b0;
        end
        else begin
            if (!PCSrc) begin
                PC <= PC + 32'd4;
            end
            else begin
                PC <= PC_next;
            end
        end
    end


endmodule