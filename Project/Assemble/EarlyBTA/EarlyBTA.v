initial begin
	        INSTR_MEM[0] = 32'hE59F1204; 
			INSTR_MEM[1] = 32'hE59F2204; 
			INSTR_MEM[2] = 32'hE59F9204; 
			INSTR_MEM[3] = 32'hE59F31EC; 
			INSTR_MEM[4] = 32'hE59F41EC; 
			INSTR_MEM[5] = 32'hE59FC1EC; 
			INSTR_MEM[6] = 32'hEA000003;
			INSTR_MEM[7] = 32'hE0015002; 
			INSTR_MEM[8] = 32'hE1896001; 
			INSTR_MEM[9] = 32'hE0427009; 
			INSTR_MEM[10] = 32'hE0428001; 
			INSTR_MEM[11] = 32'hE089A001; 
			INSTR_MEM[12] = 32'hE082B001; 
			INSTR_MEM[13] = 32'hEAFFFFFE; 
			for(i = 13; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

initial begin
            DATA_CONST_MEM[0] = 32'h00000810; 
			DATA_CONST_MEM[1] = 32'h00000820; 
			DATA_CONST_MEM[2] = 32'h00000830; 
			DATA_CONST_MEM[3] = 32'h00000005; 
			DATA_CONST_MEM[4] = 32'h00000006; 
			DATA_CONST_MEM[5] = 32'h00000003; 
			for(i = 6; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end


end
