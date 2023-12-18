module HazardUnit(
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input RegWriteE,
    input PCSrcE,
    input M_BusyE,
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
    assign ForwardM = (RA2M == WA3M) & MemWriteM & MemtoRegW & RegWriteM;

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
    // Stalling for MCycle
    wire MCycleStall;
    assign MCycleStall = M_BusyE;

    assign StallF = Idrstall || MCycleStall;
    assign StallD = Idrstall || MCycleStall;
    assign StallE = MCycleStall;
    assign FlushD = BranchStall;
    assign FlushE = Idrstall || BranchStall;
    assign FlushM = MCycleStall;

    /* END: STALL_FLUSH SIGNAL */


endmodule