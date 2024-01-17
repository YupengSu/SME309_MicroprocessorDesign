module HazardUnit(
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] WA3D,
    input M_StartD,
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input [3:0] WA3R,
    input MemtoRegE,
    input RegWriteE,
    input PCSrcE,
    input M_StartE,
    input M_BusyE,
    input M_DoneE,
    input [3:0] WA3M,
    input RegWriteM,
    input [3:0] RA2M,
    input MemWriteM,
    input [3:0] WA3W,
    input MemtoRegW,
    input RegWriteW,

    output StallF,
    output StallD,
    output FlushD,
    output StallE,
    output FlushE,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output FlushM,
    output ForwardM
    );
    
    /* BEGIN: FORWARDING SIGNAL */

    // Data forwarding for DP
    wire Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W;
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);
    
    always @(*) begin
        if (Match_1E_M && RegWriteM) begin
            ForwardAE = 2'b10;
        end
        else if (Match_1E_W && RegWriteW) begin
            ForwardAE = 2'b01;
        end
        else begin
            ForwardAE = 2'b00;
        end
    end
    always @(*) begin
        if (Match_2E_M && RegWriteM) begin
            ForwardBE = 2'b10;
        end
        else if (Match_2E_W && RegWriteW) begin
            ForwardBE = 2'b01;
        end
        else begin
            ForwardBE = 2'b00;
        end
    end

    // Data forwarding for Mem
    assign ForwardM = (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;

    /* END: FORWARDING SIGNAL */

    /* BEGIN: STALL_FLUSH SIGNAL */

    // Stalling for Load and Use
    wire Match_12D_E;
    assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E); 
    wire Idrstall;
    assign Idrstall = Match_12D_E & MemtoRegE & RegWriteE;
    // Stalling for Branch
    wire BranchStall;
    assign BranchStall = PCSrcE;
    // Stalling for No-Stall MCycle
    wire RMatch_12D_R, WMatch_3D_R;
    assign RMatch_12D_R = (RA1D == WA3R) | (RA2D == WA3R);
    assign WMatch_3D_R = (WA3D == WA3R);
    wire MCycleStall;
    assign MCycleStall = (RMatch_12D_R | WMatch_3D_R | M_StartD) & M_BusyE;

    assign StallF = Idrstall || MCycleStall || M_DoneE;
    assign StallD = Idrstall || MCycleStall || M_DoneE;
    assign StallE = MCycleStall || M_DoneE;
    assign FlushD = BranchStall;
    assign FlushE = Idrstall || BranchStall || MCycleStall;
    assign FlushM = M_StartE;

    /* END: STALL_FLUSH SIGNAL */


endmodule