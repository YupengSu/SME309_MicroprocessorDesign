module Comparator (
    input [31:0] Com_Src1,
    input [31:0] Com_Src2,

    input [2:0] ComControl,

    output reg ComResult
);

/***********************************************************************************************************************
// _* ComControl | operation
// _*       3'h0 | ==       
// _*       3'h1 | !=       
// _*       3'h2 | nothing  
// _*       3'h3 | nothing  
// _*       3'h4 | <        
// _*       3'h5 | >=       
// _*       3'h6 | < (u)    
// _*       3'h7 | >= (u)   

***********************************************************************************************************************/

    wire equal;
    wire less_than;
    wire less_than_u;

    assign equal = (Com_Src1 == Com_Src2) ? 1'b1 : 1'b0;
    assign less_than = ($signed(Com_Src1) < $signed(Com_Src2)) ? 1'b1 : 1'b0;
    assign less_than_u = (Com_Src1 < Com_Src2) ? 1'b1 : 1'b0;

    always @(*) begin
        case (ComControl)
            3'b000: begin
                ComResult = equal;
            end
            3'b001: begin
                ComResult = ~equal;
            end
            3'b010: begin
                ComResult = 1'b1;
            end
            3'b011: begin
                ComResult = 1'b1;
            end
            3'b100: begin
                ComResult = less_than;
            end
            3'b101: begin
                ComResult = ~less_than;
            end
            3'b110: begin
                ComResult = less_than_u;
            end
            3'b110: begin
                ComResult = ~less_than_u;
            end
            default: begin
                ComResult = 1'b1;
            end
        endcase
    end

endmodule