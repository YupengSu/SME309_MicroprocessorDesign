module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [2:0] ALUControl,

    output reg [31:0] ALUResult,
    output [3:0] ALUFlags,
    
    input Carry,
    input Carry_used,

    input Reverse_B
    );
    wire Carry_trans;
    wire Carry_fixed;
    wire [31:0] Src_B_mid;
    wire [31:0] Src_B_fixed;
    reg Cout;
    wire N, Z, C, V;

    // ================================================
    //               Arithmetic Operation
    // ================================================
    assign Carry_trans = ALUControl[0] ? !Carry : Carry;
    assign Carry_fixed = Carry_trans & Carry_used;
    assign Src_B_mid = ALUControl[0]? ~Src_B : Src_B;
    assign Src_B_fixed = Reverse_B ? ~ Src_B : Src_B;
    
    always @(*) begin
        case(ALUControl)
            3'b000:  {Cout, ALUResult} = ALUControl[0]?(Src_A + Src_B_mid + 1'b1 + Carry_fixed):(Src_A + Src_B_mid + Carry_fixed);// Add
            3'b001:  {Cout, ALUResult} = ALUControl[0]?(Src_A + Src_B_mid + 1'b1 - Carry_fixed):(Src_A + Src_B_mid - Carry_fixed);// Sub
            3'b010:  ALUResult = Src_A & Src_B_fixed;// And & BIC
            3'b011:  ALUResult = Src_A | Src_B;// ORR
            3'b100:  ALUResult = Src_A ^ Src_B;// EOR
            3'b101:  ALUResult = Src_B_fixed;// MOV & MVN
            default: ALUResult = 32'd0;
        endcase
    end    
    // ================================================
    //               ALUFlags Generation
    // ================================================
    assign N = ALUResult[31];
    assign Z = ALUResult == 32'b0;
    assign C = Cout & ~ALUControl[1];
    assign V = ~(Src_A[31]^Src_B[31]^ALUControl[0]) & (Src_A[31]^ALUResult[31]) & ~ALUControl[1]; 

    assign ALUFlags = {N,Z,C,V};
    

endmodule













