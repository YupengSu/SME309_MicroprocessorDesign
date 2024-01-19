	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	;LDR R1, constant1; R1=5
	;LDR R2, constant2; R2=6
	;LDR R9, constant3; R9=3
	;LDR R3, addr1; 810
	;LDR R4, addr2; 820
	;LDR R12,addr3; 830
	
	;ADD R5, R1, R2;
	;ADD R6, R1, R9;
	;ADD R7, R2, R9;
	
	;MUL R8, R1, R2;
	;MUL R10, R2, R9;
	
	LDR R1, constant4;
	LDR R2, constant5;
	LDR R3, constant6;
	LDR R4, constant7;
	LDR R5, constant8;
		
	MUL R6, R1, R2;
	MUL R7, R1, R3;
	MUL R8, R1, R4;
	MUL R9, R1, R5;
	
	;DIV R6, R1, R2;
	;DIV R7, R1, R3;
	;DIV R8, R1, R4;
	;DIV R9, R1, R5;
	;ADD R5, R1, R2; R5 = a1 + a2
	;Data Forwarding for DP
	;ADD R5, R1, R2
	;SUB R6, R5, R9
	;ADD R7, R1, R5
	;SUB R8, R5, R2
	
	;STR R7, [R12]
	;Data Forwarding Testing(Memory-Memory Copy)
	;ADD R5, R1, R2
	;STR R5, [R3,#4];
	;ADD R3, R3, #8;
	;LDR R6, [R3,#-4]; R5 = 11;
	;STR R6, [R4,#4]
	
	;Early BTA Test
	;B   2C in wrapper, we will insert jump instructions manually.
	;AND R5, R1, R2
	;ORR R6, R9, R1
	;SUB R7, R2, R9
	;SUB R8, R2, R1
	;ADD R10, R9, R1
	;ADD R11, R2, R1
	
	;Load and Use Test(whether stall?)
	;ADD R5, R1, R2
	;STR R5, [R3,#4];
	;ADD R3, R3, #8;
	;LDR R6, [R3,#-4]; R5 = 11;
	;SUB R7, R6, R1
	
	;Non-stalling CPU
	;multiply
	;MUL R5, R1, R2
	;ADD R6, R2, R9
	;divide
	
	;Stalling CPU
	;MUL R5, R1, R2
	;ADD R6, R5, R9
	;SUB R6, R2, R1;  R6 = 1;
	;STR R6, [R4,#-4];
	;SUB R4, R4, #8;
	;LDR R6,[R4,#4];	 R6 = 1;
	
	;MUL R7,R5,R2;R7=66
	;LDR R8,constant3; R8=3
	;LDR R3,number0;R3=0
	;MULEQ R7,R1,R8; not execute,R7=66
	;ADDS R3,R3,#0; SET Z FLAG = 1
	;MULEQ R10,R1,R8; R10=15;
	;ADDS R10,R10,R7; R10 =66+15=81,flags are 0
	
	;ADD R3,R3,#0;;DIV R7,R7,R8; R7=66/3=22
	;ADD R3,R3,#0;;DIV R7,R7,R1; R7=22/5=4
	;ADD R3,R3,#0;;DIVEQ R7,R2,R8; not execute, R7 = 4
	;ADDS R3,R3,#0; SET Z FLAG = 1
	;ADD R3,R3,#0;;DIVEQ R11,R2,R8;R11=6/3=2;
	;ADD R11,R11,R7; R11=2+4=6
	;ADD R11,R11,R10;R11=81+6=87=0X0000 0057

	;STR R11,[R12];
	
halt	
	B    halt
	
; ------- <code memory (ROM mapped to Instruction Memory) begins>
	
	
	
	

; ------- <code memory (ROM mapped to DATA Memory) begins>
	AREA    CONSTANTS, DATA, READONLY, ALIGN=9 


addr1
		DCD 0x00000810;
addr2 	
		DCD 0x00000820;
addr3
		DCD 0x00000830;
constant1
		DCD 0x00000005; 
constant2
		DCD 0x00000006;
constant3 
		DCD 0x00000003;
		
			
constant4 
		DCD 0x3FA66666;1.3
constant5 
		DCD 0x00000000;0.0
constant6
		DCD 0x7F800000;infinite
constant7
		DCD 0xFF800000;Neg infinite
constant8
		DCD 0xFFFFFFFF;NaN

			

number0
		DCD 0x00000000;




		END	