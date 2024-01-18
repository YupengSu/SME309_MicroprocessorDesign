module Extend(
    input [2:0] ImmSrc,
    input [31:0] Instr,
    input sign,

    output reg [31:0] ExtImm
    );  

    always @(*) begin
        case (ImmSrc)
            3'd1: begin: R_type
                ExtImm = 32'b0;
            end
            3'd2: begin: I_type
                ExtImm[11:0] = Instr[31:20];
                ExtImm[31:12] = sign ? {20{Instr[31]}} : 20'b0;
            end
            3'd3: begin: S_type 
                ExtImm[4:0] = Instr[11:7];
                ExtImm[11:5] = Instr[31:25];
                // ExtImm[31:12] = sign ? {19{Instr[31]}} : 19'b0;
                ExtImm[31:12] = {20{Instr[31]}};
            end
            3'd4: begin: B_type
                ExtImm[0] = 1'b0;
                ExtImm[11] = Instr[7];
                ExtImm[4:1] = Instr[11:8];
                ExtImm[10:5] = Instr[30:25];
                ExtImm[12] = Instr[31];
                // ExtImm[31:13] = sign ? {18{Instr[31]}} : 18'b0;
                ExtImm[31:13] = {19{Instr[31]}};
            end
            3'd5: begin: J_type
                ExtImm[0] = 1'b0;
                {ExtImm[20], ExtImm[10:1], ExtImm[11], ExtImm[19:12]} = Instr[31:12];
                // ExtImm[31:21] = sign ? {11{Instr[31]}} : 11'b0;
                ExtImm[31:21] = {11{Instr[31]}};
            end 
            default: begin
                ExtImm = 32'b0;
            end
        endcase
    end
    
endmodule
