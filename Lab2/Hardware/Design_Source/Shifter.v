module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output reg [31:0] ShOut
    );

    // ========================================
    //           Logical Shift Left
    // ========================================
    wire [31:0] ShOutLSLA, ShOutLSLB, ShOutLSLC, ShOutLSLD, ShOutLSL;
    assign ShOutLSLA = Shamt5[4]? {ShIn[31:16],{16{1'b0}}}: ShIn;
    assign ShOutLSLB = Shamt5[3]? {ShOutLSLA[31:8],{8{1'b0}}}: ShOutLSLA;
    assign ShOutLSLC = Shamt5[2]? {ShOutLSLB[31:4],{4{1'b0}}}: ShOutLSLB;
    assign ShOutLSLD = Shamt5[1]? {ShOutLSLC[31:2],{2{1'b0}}}: ShOutLSLC;
    assign ShOutLSL  = Shamt5[0]? {ShOutLSLD[31:1],{1{1'b0}}}: ShOutLSLD;

     // ========================================
    //           Logical Shift Right
    // ========================================   
    wire [31:0] ShOutLSRA, ShOutLSRB, ShOutLSRC, ShOutLSRD, ShOutLSR;
    assign ShOutLSRA = Shamt5[4]? {{16{1'b0}},ShIn[31:16]}: ShIn;
    assign ShOutLSRB = Shamt5[3]? {{8{1'b0}},ShOutLSRA[31:8]}: ShOutLSRA;
    assign ShOutLSRC = Shamt5[2]? {{4{1'b0}},ShOutLSRB[31:4]}: ShOutLSRB;
    assign ShOutLSRD = Shamt5[1]? {{2{1'b0}},ShOutLSRC[31:2]}: ShOutLSRC;
    assign ShOutLSR  = Shamt5[0]? {{1{1'b0}},ShOutLSRD[31:1]}: ShOutLSRD;

    // ========================================
    //           Arithmetic Shift Right
    // ========================================
    wire [31:0] ShOutASRA, ShOutASRB, ShOutASRC, ShOutASRD, ShOutASR;
    assign ShOutASRA = Shamt5[4]? {{16{ShIn[31]}},ShIn[31:16]}: ShIn;
    assign ShOutASRB = Shamt5[3]? {{8{ShOutASRA[31]}},ShOutASRA[31:8]}: ShOutASRA;
    assign ShOutASRC = Shamt5[2]? {{4{ShOutASRB[31]}},ShOutASRB[31:4]}: ShOutASRB;
    assign ShOutASRD = Shamt5[1]? {{2{ShOutASRC[31]}},ShOutASRC[31:2]}: ShOutASRC;
    assign ShOutASR  = Shamt5[0]? {{1{ShOutASRD[31]}},ShOutASRD[31:1]}: ShOutASRD;

    // ========================================
    //               Rotate Right
    // ========================================
    wire [31:0] ShOutRORA, ShOutRORB, ShOutRORC, ShOutRORD, ShOutROR;
    assign ShOutRORA = Shamt5[4]? {ShIn[15:0],ShIn[31:16]}: ShIn;
    assign ShOutRORB = Shamt5[3]? {ShOutRORA[7:0],ShOutRORA[31:8]}: ShOutRORA;
    assign ShOutRORC = Shamt5[2]? {ShOutRORB[3:0],ShOutRORB[31:4]}: ShOutRORB;
    assign ShOutRORD = Shamt5[1]? {ShOutRORC[1:0],ShOutRORC[31:2]}: ShOutRORC;
    assign ShOutROR  = Shamt5[0]? {ShOutRORD[0],ShOutRORD[31:1]}: ShOutRORD;

    always @(*) begin
        case (Sh)
            2'b00: ShOut[31:0] = ShOutLSL[31:0];
            2'b01: ShOut[31:0] = ShOutLSR[31:0];
            2'b10: ShOut[31:0] = ShOutASR[31:0];
            2'b11: ShOut[31:0] = ShOutROR[31:0];
        endcase
    end
     
endmodule 
