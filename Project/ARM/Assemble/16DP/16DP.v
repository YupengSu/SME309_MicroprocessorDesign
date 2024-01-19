
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE59F1204; 
			INSTR_MEM[1] = 32'hE59F2204; 
			INSTR_MEM[2] = 32'hE59F31F0; 
			INSTR_MEM[3] = 32'hE59F41F0; 
			INSTR_MEM[4] = 32'hE59FC1F0; 
			INSTR_MEM[5] = 32'hE2015001; 
			INSTR_MEM[6] = 32'hE0026003; 
			INSTR_MEM[7] = 32'hE0217002; 
			INSTR_MEM[8] = 32'hE0218001; 
			INSTR_MEM[9] = 32'hE1819002; 
			INSTR_MEM[10] = 32'hE3A05000; 
			INSTR_MEM[11] = 32'hE1816001; 
			INSTR_MEM[12] = 32'hE172000C; 
			INSTR_MEM[13] = 32'hE3110000; 
			INSTR_MEM[14] = 32'hE3310000; 
			INSTR_MEM[15] = 32'hE2677007; 
			INSTR_MEM[16] = 32'hE2A88001; 
			INSTR_MEM[17] = 32'hE3510006; 
			INSTR_MEM[18] = 32'hE2E99009; 
			INSTR_MEM[19] = 32'hE2C15002; 
			INSTR_MEM[20] = 32'hE3E06000; 
			INSTR_MEM[21] = 32'hE3C17004; 
			INSTR_MEM[22] = 32'hE58C7000; 
			INSTR_MEM[23] = 32'hEAFFFFFE; 
			for(i = 24; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

//----------------------------------------------------------------
// Data (Constant) Memory
//----------------------------------------------------------------
initial begin
			DATA_CONST_MEM[0] = 32'h00000810; 
			DATA_CONST_MEM[1] = 32'h00000820; 
			DATA_CONST_MEM[2] = 32'hFFFFFFFF; 
			DATA_CONST_MEM[3] = 32'h00000005; 
			DATA_CONST_MEM[4] = 32'h00000006; 
			DATA_CONST_MEM[5] = 32'h00000003; 
			for(i = 6; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

