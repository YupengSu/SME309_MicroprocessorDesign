/* REGISTERFILE: READ/WRITE REGBANK */
module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] A1,
    input [3:0] A2,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,

    output [31:0] RD1,
    output [31:0] RD2
    );
    
    
    // declare RegBank
    reg [31:0] RegBank[0:14] ;

    // Read Operation: Combinational Logical
    assign RD1 = (A1 != 4'd15)? RegBank[A1]: R15;
    assign RD2 = (A2 != 4'd15)? RegBank[A2]: R15;

    // Write Operation: Sequential Logical
    always @(negedge CLK) begin
        if (WE3) begin
            RegBank[A3] <= WD3;
        end
        else begin
            RegBank[A3] <= RegBank[A3];
        end
    end
    
endmodule