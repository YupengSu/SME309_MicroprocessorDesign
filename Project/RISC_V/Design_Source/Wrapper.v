`timescale 1ns / 1ps
//>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is used as a component in TOP.v for Synthesis) ******* <<<<<<<<<<<<

module Wrapper #(
    parameter N_LEDs = 16,  // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs+1). 16 by default
    parameter N_DIPs = 7    // Number of DIPs. 16 by default	                             
) (
    input      [N_DIPs-1:0] DIP,          // DIP switch inputs, used as a user definied memory address for checking memory content.
    output reg [N_LEDs-1:0] LED,          // LED light display. Display the value of program counter.
    output reg [      31:0] SEVENSEGHEX,  // 7 Seg LED Display. The 32-bit value will appear as 8 Hex digits on the display. Used to display memory content.
    input                   RESET,        // Active high.
    input                   CLK           // Divided Clock from TOP.
);

    //----------------------------------------------------------------
    // ARM signals
    //----------------------------------------------------------------
    wire [31:0] PC;
    wire [31:0] Instr;
    reg  [31:0] ReadData;
    wire [ 1:0] MemWrite;
    wire [31:0] ALUResult;
    wire [31:0] WriteData;

    //----------------------------------------------------------------
    // Address Decode signals
    //---------------------------------------------------------------
    wire dec_DATA_CONST, dec_DATA_VAR;  // 'enable' signals from data memory address decoding

    //----------------------------------------------------------------
    // Memory read for IO signals
    //----------------------------------------------------------------
    wire    [31:0] ReadData_IO;

    //----------------------------------------------------------------
    // Memory declaration
    //-----------------------------------------------------------------
    reg     [31:0] INSTR_MEM     [0:127];  // instruction memory
    reg     [31:0] DATA_CONST_MEM[0:127];  // data (constant) memory
    reg     [31:0] DATA_VAR_MEM  [0:127];  // data (variable) memory
    integer        i;


    //----------------------------------------------------------------
    // Instruction Memory
    //----------------------------------------------------------------
    initial begin
        INSTR_MEM[0]  = 32'b0_00_0000_0100_0_0000_0000_0000_1101111; // jalr #4          r0 = 0x4
        INSTR_MEM[1]  = 32'b0_00_0000_0100_0_0000_0000_0001_1101111; // jalr #4          r1 = 0x8
        INSTR_MEM[2]  = 32'b0000000_00000_00001_000_00010_0110011;   // add r2, r1, r0   r2 = 0xc
        INSTR_MEM[3]  = 32'b0100000_00001_00010_000_00011_0110011;   // sub r3, r2, r1   r3 = 0x4
        INSTR_MEM[4]  = 32'b0000000_00010_00001_010_00100_0110011;   // slt r4, r1, r2   r4 = 0x1
        INSTR_MEM[5]  = 32'b0000000_00001_00010_011_00101_0110011;   // sltu r5, r2, r1   r5 = 0x0
		INSTR_MEM[6]  = 32'b0000_0000_1011_00000_000_00110_0010011;   // addi r6, r0, #11   r6 = 0xf
		INSTR_MEM[7]  = 32'b0000_0001_0011_00110_010_00111_0010011;   // slti r7, r6, #19   r7 = 0x1
		INSTR_MEM[8]  = 32'b0000_0000_1111_00110_011_01000_0010011;   // sltiu r8, r6, #15   r8 = 0x0
		INSTR_MEM[9]  = 32'b0001_1111_1111_00100_000_01001_0000011;   // lb r9, r4, #511   r9 = 0x10
		INSTR_MEM[10] = 32'b0000_0001_0100_00100_000_01010_0010011;   // addi r10, r4, #20   r10 = 0x5
		INSTR_MEM[11] = 32'b0001_1111_1111_01010_001_01011_0000011;   // lh r11, r10, #511   r11 = 0xFFFF
		INSTR_MEM[12] = 32'b0000_0000_0100_01010_000_01100_0010011;   // addi r12, r10, #4   r12 = 0d19
		INSTR_MEM[13] = 32'b0001_1111_1111_01100_010_01101_0000011;   // lw r13, r12, #511   r11 = 0xFEF9FFF9
        for (i = 14; i < 128; i = i + 1) begin
            INSTR_MEM[i] = 32'h0;
        end
    end

    //----------------------------------------------------------------
    // Data (Constant) Memory
    //----------------------------------------------------------------
    initial begin
        DATA_CONST_MEM[0] = 32'h00000810;
        DATA_CONST_MEM[1] = 32'h00000820;
        DATA_CONST_MEM[2] = 32'h00000830;
        DATA_CONST_MEM[3] = 32'h00000002;
        DATA_CONST_MEM[4] = 32'h00000001;
        DATA_CONST_MEM[5] = 32'hFFFFFFFF;
        DATA_CONST_MEM[6] = 32'hFEF9FFF9;
        for (i = 7; i < 128; i = i + 1) begin
            DATA_CONST_MEM[i] = 32'h0;
        end
    end

    //----------------------------------------------------------------
    // Data (Variable) Memory
    //----------------------------------------------------------------
    initial begin
        for (i = 0; i < 128; i = i + 1) begin
            DATA_VAR_MEM[i] = 32'h0;
        end
    end


    //----------------------------------------------------------------
    // ARM port map
    //----------------------------------------------------------------
    ARM ARM1 (
        CLK,
        RESET,
        Instr,
        ReadData,
        MemWrite,
        PC,
        ALUResult,
        WriteData
    );

    //----------------------------------------------------------------
    // Data memory address decoding
    //----------------------------------------------------------------
    assign dec_DATA_CONST = (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
    assign dec_DATA_VAR   = (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;

    //----------------------------------------------------------------
    // Data memory read 1
    //----------------------------------------------------------------
    always @(*) begin
        if (dec_DATA_VAR) ReadData <= DATA_VAR_MEM[ALUResult[8:2]];
        else if (dec_DATA_CONST) ReadData <= DATA_CONST_MEM[ALUResult[8:2]];
        else ReadData <= 32'h0;
    end

    //----------------------------------------------------------------
    // Data memory read 2
    //----------------------------------------------------------------
    assign ReadData_IO = DATA_VAR_MEM[DIP[6:0]];

    //----------------------------------------------------------------
    // Data Memory write
    //----------------------------------------------------------------
    always @(posedge CLK) begin
        if (MemWrite && dec_DATA_VAR) begin
			case (MemWrite)
				2'b00: begin
					DATA_VAR_MEM[ALUResult[8:2]] <= DATA_VAR_MEM[ALUResult[8:2]];
				end 
				2'b01: begin
					DATA_VAR_MEM[ALUResult[8:2]] <= {{24{WriteData[7]}}, WriteData[7:0]};
				end 
				2'b10: begin
					DATA_VAR_MEM[ALUResult[8:2]] <= {{16{WriteData[15]}}, WriteData[15:0]};
				end 
				2'b11: begin
					DATA_VAR_MEM[ALUResult[8:2]] <= WriteData;
				end 
				default: begin
					DATA_VAR_MEM[ALUResult[8:2]] <= DATA_VAR_MEM[ALUResult[8:2]];
				end
			endcase
		end
		else;
    end

    //----------------------------------------------------------------
    // Instruction memory read
    //----------------------------------------------------------------
    assign Instr = ((PC >= 32'h00000000) && (PC <= 32'h000001FC)) ?  // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
        INSTR_MEM[PC[8:2]] : 32'h00000000;

    //----------------------------------------------------------------
    // LED light - display PC value
    //----------------------------------------------------------------
    always @(posedge CLK or posedge RESET) begin
        if (RESET) LED <= 'b0;
        else LED <= PC;
    end

    //----------------------------------------------------------------
    // SevenSeg LED - display memory content
    //----------------------------------------------------------------
    always @(posedge CLK or posedge RESET) begin
        if (RESET) SEVENSEGHEX <= 32'b0;
        else SEVENSEGHEX <= ReadData_IO;
    end

endmodule
