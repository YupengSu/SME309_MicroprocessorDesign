module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,
    input M_Busy,
    
    output [31:0] PC,
    output [31:0] PC_Plus_4
); 

    reg [31:0] current_PC;
    wire [31:0] next_PC;

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            current_PC <= 32'b0;
        end
        // MC01.MCycle Busy, PC unchanged
        else if (!M_Busy) begin
            current_PC <= next_PC;
        end
        else begin
            current_PC <= current_PC;
        end
    end

    assign PC = current_PC;
    assign PC_Plus_4 = current_PC + 32'd4;
    assign next_PC = PCSrc? Result: PC_Plus_4;

endmodule