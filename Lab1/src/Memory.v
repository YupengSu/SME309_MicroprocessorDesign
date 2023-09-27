module Memory(
    input clk,
	input rst_n,

    input [7:0] mem_addr,
    output [31:0] data
);

integer i;
reg [31:0] INSTR_MEM [127:0];
reg [31:0] DATA_CONST_MEM [127:0];

//----------------------------------------------
//             Instruction Memory
//----------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE3A00000; 
			INSTR_MEM[1] = 32'hE1A0100F; 
			INSTR_MEM[2] = 32'hE0800001; 
			INSTR_MEM[3] = 32'hE2511001; 
			INSTR_MEM[4] = 32'h1AFFFFFC; 
			INSTR_MEM[5] = 32'hE59F01E8; 
			INSTR_MEM[6] = 32'hE58F57E0; 
			INSTR_MEM[7] = 32'hE59F57DC; 
			INSTR_MEM[8] = 32'hE59F21D8; 
			INSTR_MEM[9] = 32'hE5820000; 
			INSTR_MEM[10] = 32'hE5820004; 
			INSTR_MEM[11] = 32'hEAFFFFFE; 
			for(i = 12; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

//----------------------------------------------
//           Data (Constant) Memory
//----------------------------------------------
initial begin
			DATA_CONST_MEM[0] = 32'h00000800; 
			DATA_CONST_MEM[1] = 32'hABCD1234; 
			for(i = 2; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

assign data = mem_addr[7] == 1? DATA_CONST_MEM[mem_addr[6:0]] : INSTR_MEM[mem_addr[6:0]];

endmodule