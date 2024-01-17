module ALU(
    input [31:0] ALU_Src_A,
    input [31:0] ALU_Src_B,
    input [1:0] ALUControl,

    output [31:0] ALUResult
    // output [3:0] ALUFlags
    );

    /***********************************************************************************************************************
    // _* ALUControl | operation
    // _*       2'00 | add(i)   
    // _*       2'01 | sub      
    // _*       2'10 | slt(i)   
    // _*       2'11 | slt(i)u  
    ***********************************************************************************************************************/

    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;

    assign add_result = ALU_Src_A + ALU_Src_B;
    assign sub_result = ALU_Src_A - ALU_Src_B;
    assign slt_result = $signed(ALU_Src_A) < $signed(ALU_Src_B) ? 32'b1 : 32'b0;
    assign sltu_result = ALU_Src_A < ALU_Src_B ? 32'b1 : 32'b0;

    assign ALUResult = (ALUControl == 2'b00) ? add_result :(
                        (ALUControl == 2'b01) ? sub_result : (
                        (ALUControl == 2'b10) ? slt_result : (sltu_result)));
        
endmodule













