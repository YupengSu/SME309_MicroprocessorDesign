
module MCycleReg(
    input CLK,

    input M_StartE,
    input M_DoneE,

    input [31:0] InstrE,
    input RegWriteE,
    input MemWriteE,
    input MemtoRegE,
    input [31:0] WriteDataE,
    input [3:0] RA2E,
    input [3:0] WA3E,

    input [31:0] MCycleResultE,
    input [31:0] ALUResultE,

    output [31:0] InstrRE,
    output RegWriteRE,
    output MemWriteRE,
    output MemtoRegRE,
    output [31:0] WriteDataRE,
    output [3:0] RA2RE,
    output [3:0] WA3RE,
    output [31:0] OpResultRE,

    output reg [3:0] WA3R
    );
    // Save MCycle Registers
    reg [31:0] InstrR;
    reg RegWriteR;
    reg MemWriteR;
    reg MemtoRegR;
    reg [31:0] WriteDataR;
    reg [3:0] RA2R;

    always @(negedge CLK) begin
        if (M_StartE) begin // Start: save the MCycle Registers
            InstrR <= InstrE;
            RegWriteR <= RegWriteE;
            MemWriteR <= MemWriteE;
            MemtoRegR <= MemtoRegE;
            WriteDataR <= WriteDataE;
            RA2R <= RA2E;
            WA3R <= WA3E;
        end
        else begin // Not Start: hold the MCycle Registers
            InstrR <= InstrR;
            RegWriteR <= RegWriteR;
            MemWriteR <= MemWriteR;
            MemtoRegR <= MemtoRegR;
            WriteDataR <= WriteDataR;
            RA2R <= RA2R;
            WA3R <= WA3R;
        end
    end

    // Output the MCycle Registers
    assign InstrRE = M_DoneE? InstrR: InstrE;
    assign RegWriteRE = M_DoneE? RegWriteR: RegWriteE;
    assign MemWriteRE = M_DoneE? MemWriteR: MemWriteE;
    assign MemtoRegRE = M_DoneE? MemtoRegR: MemtoRegE;
    assign WriteDataRE = M_DoneE? WriteDataR: WriteDataE;
    assign RA2RE = M_DoneE? RA2R: RA2E;
    assign WA3RE = M_DoneE? WA3R: WA3E;
    assign OpResultRE = M_DoneE? MCycleResultE: ALUResultE;

endmodule