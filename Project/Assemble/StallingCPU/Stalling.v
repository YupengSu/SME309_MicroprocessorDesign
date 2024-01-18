
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE59F1204; 
			INSTR_MEM[1] = 32'hE59F2204; 
			INSTR_MEM[2] = 32'hE59F9204; 
			INSTR_MEM[3] = 32'hE0050291; 
			INSTR_MEM[4] = 32'hE0856009; 
			INSTR_MEM[5] = 32'hEAFFFFFE; 
			for(i = 6; i < 128; i = i+1) begin 
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
			DATA_CONST_MEM[3] = 32'h00000005; 
			DATA_CONST_MEM[4] = 32'h00000006; 
			DATA_CONST_MEM[5] = 32'h00000003; 
			DATA_CONST_MEM[6] = 32'h3FA66666; 
			DATA_CONST_MEM[7] = 32'h00000000; 
			DATA_CONST_MEM[8] = 32'h7F800000; 
			DATA_CONST_MEM[9] = 32'hFF800000; 
			DATA_CONST_MEM[10] = 32'hFFFFFFFF; 
			for(i = 11; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

