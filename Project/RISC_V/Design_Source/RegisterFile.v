module RegisterFile(
    input CLK,
    input [1:0] WE3, // 00: no write; 01: byte; 10: half; 11: word
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,

    input sign_for_reg,

    output [31:0] RD1,
    output [31:0] RD2
    );
    
    // declare RegBank
    reg [31:0] RegBank[0:31] ;

    assign RD1 = RegBank[A1];
    assign RD2 = RegBank[A2];

    always @(posedge CLK) begin
        case (WE3)
            2'b00: begin
                RegBank[A3] <= RegBank[A3];
            end
            2'b01: begin
                RegBank[A3][7:0] <= WD3[7:0];
                RegBank[A3][31:8] <= sign_for_reg ? {24{WD3[7]}} : 24'b0; 
            end
            2'b10: begin
                RegBank[A3][15:0] <= WD3[15:0];
                RegBank[A3][31:16] <= sign_for_reg ? {16{WD3[15]}} : 16'b0;
            end
            2'b11: begin
                RegBank[A3] <= WD3;
            end
            default: begin
                RegBank[A3] <= 32'bx;
            end
        endcase
    end
    
endmodule