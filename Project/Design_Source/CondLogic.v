module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input MemW,
    input NoWrite,
    input [1:0] FlagW,
    input [3:0] Cond,
    input [3:0] ALUFlags,
    
    output PCSrc,
    output RegWrite,
    output MemWrite
    ); 
    reg CondEx;
    reg N = 0, Z = 0, C = 0, V = 0;

    // ===============================================
    //             Flags Register Update
    // ===============================================
    always @(posedge CLK) begin
        if (FlagW[1] && CondEx) begin
            {N,Z} <= ALUFlags[3:2];
        end
        else begin
            {N,Z} <= {N,Z};
        end   
    end

    always @(posedge CLK) begin
        if (FlagW[0] && CondEx) begin
            {C,V} <= ALUFlags[1:0];
        end
        else begin
            {C,V} <= {C,V};
        end   
    end

    // ================================================
    //      ‘CondEX’ generate: use case statement
    // ================================================
    always @(*) begin
        case(Cond)
            4'b0000: CondEx = Z;
            4'b0001: CondEx = ~Z;
            4'b0010: CondEx = C;
            4'b0011: CondEx = ~C;
            4'b0100: CondEx = N;
            4'b0101: CondEx = ~N;
            4'b0110: CondEx = V;
            4'b0111: CondEx = ~V;
            4'b1000: CondEx = C & ~Z;
            4'b1001: CondEx = ~C | Z;
            4'b1010: CondEx = ~(N ^ V);
            4'b1011: CondEx = N ^ V;
            4'b1100: CondEx = ~Z & ~(N ^ V);
            4'b1101: CondEx = Z | (N ^ V);
            4'b1110: CondEx = 1;
            default: CondEx = 0;
        endcase
    end

    // ================================================
    //                   output stage
    // ================================================
    
    assign PCSrc    = CondEx & PCS ;
    assign RegWrite = CondEx & RegW & ~NoWrite;
    assign MemWrite = CondEx & MemW;
    
endmodule