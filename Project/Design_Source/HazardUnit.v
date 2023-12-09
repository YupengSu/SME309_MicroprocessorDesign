module HazardUnit(
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input PCSrcE,
    input M_BusyE,
    input [3:0] WA3M,
    input RegWriteM,
    input [3:0] RA2M,
    input MemWriteM,
    input [3:0] WA3W,
    input RegWriteW,

    output StallF,
    output StallD,
    output FlushD,
    output StallE,
    output FlushE,
    output [1:0] ForwardAE,
    output [1:0] ForwardBE,
    output FlushM,
    output ForwardM
    );
    // TODO: Your code here
endmodule