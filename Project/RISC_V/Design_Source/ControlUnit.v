module ControlUnit (
    input [31:0] Instr,
    // input [3:0] ALUFlags,
    input        CLK,

    output           MemtoReg,
    output reg [1:0] MemWrite, // 00: no write; 01: byte; 10: half; 11: word
    output reg [1:0] ALUSrc,
    output reg [2:0] ImmSrc,    /////////
    output reg [1:0] RegWrite, // 00: no write; 01: byte; 10: half; 11: word
    output reg [1:0] ALUControl,
    output           PCSrc_out,
    output           RegSrc,

    output [2:0] ComControl,
    output reg sign,
    output reg sign_for_reg
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];

    assign MemtoReg = (opcode == 7'b0000011);
    //assign MemWrite = (opcode == 7'b0100011);
    //assign RegWrite = ~((opcode == 7'b0100011) | (opcode == 7'b1100011));
    assign PCSrc_out = (opcode == 7'b1100011) | (opcode == 7'b1101111) | (opcode == 7'b1100111);
    assign ComControl = (opcode == 7'b1100011) ? funct3 : 3'h2;
    assign RegSrc = (opcode == 7'b1101111);

    always @(*) begin
        case (opcode)
            7'b0110011: begin
                ImmSrc = 3'd1;
                MemWrite = 2'b00;
                RegWrite = 2'b11;
                ALUSrc = 2'b11;
                if (funct3 == 3'h0) begin: add_or_sub
                    sign = 1'b1;
                    if (funct7 == 7'h00) begin: add
                        ALUControl = 2'b00;
                    end
                    else begin: sub
                        ALUControl = 2'b01;
                    end
                end
                else if (funct3 == 3'h2) begin: slt
                    sign = 1'b1;
                    ALUControl = 2'b10;
                end 
                else begin: sltu
                    sign = 1'b0;
                    ALUControl = 2'b11;
                end
            end
            7'b0010011: begin
                ImmSrc = 3'd2;
                MemWrite = 2'b00;
                RegWrite = 2'b11;
                ALUSrc = 2'b10;
                if (funct3 == 3'h0) begin: addi
                    sign = 1'b1;
                    ALUControl = 2'b00;
                end
                else if (funct3 == 3'h2) begin: slti
                    sign = 1'b1;
                    ALUControl = 2'b10;
                end
                else begin: sltiu
                    sign = 1'b0;
                    ALUControl = 2'b11;
                end
            end
            7'b0000011: begin
                ImmSrc = 3'd2;
                MemWrite = 2'b00;
                ALUSrc = 2'b10;
                ALUControl = 2'b00;
                case (funct3)
                    3'h0: begin
                        sign_for_reg = 1'b1;
                        sign = 1'b1;
                        RegWrite = 2'b01;
                    end 
                    3'h1: begin
                        sign_for_reg = 1'b1;
                        sign = 1'b1;
                        RegWrite = 2'b10;
                    end 
                    3'h2: begin
                        sign_for_reg = 1'b1;
                        sign = 1'b1;
                        RegWrite = 2'b11;
                    end 
                    3'h4: begin
                        sign_for_reg = 1'b0;
                        sign = 1'b1;
                        RegWrite = 2'b01;
                    end 
                    3'h5: begin
                        sign_for_reg = 1'b0;
                        sign = 1'b1;
                        RegWrite = 2'b10;
                    end 
                    default: begin
                        sign = 1'b1;
                        RegWrite = 2'b11;
                    end
                endcase
            end
            7'b0100011: begin
                sign = 1'b1;
                ImmSrc = 3'd3;
                MemWrite = funct3 + 3'b1;
                RegWrite = 2'b00;
                ALUSrc = 2'b10;
                ALUControl = 2'b00;
            end
            7'b1100011: begin
                ImmSrc = 3'd4;
                MemWrite = 2'b00;
                RegWrite = 2'b00;
                ALUSrc = 2'b00;
                ALUControl = 2'b00;
                if (funct3 == 3'h6 || funct3 == 3'h7) begin
                    sign = 1'b0;
                end
                else begin
                    sign = 1'b1;
                end
            end
            7'b1101111: begin
                sign = 1'b1;
                ImmSrc = 3'd5;
                MemWrite = 2'b00;
                RegWrite = 2'b11;
                ALUSrc = 2'b00;
                ALUControl = 2'b00;
            end
            7'b1100111: begin
                sign = 1'b1;
                ImmSrc = 3'd2;
                MemWrite = 2'b00;
                RegWrite = 2'b11;
                ALUSrc = 2'b10;
                ALUControl = 2'b00;
            end
            default: begin
                sign = 1'b1;
                ImmSrc = 3'd0;
                MemWrite = 2'b00;
                RegWrite = 2'b00;
                ALUSrc = 2'b00;
                ALUControl = 2'b00;
            end
        endcase
    end

endmodule
