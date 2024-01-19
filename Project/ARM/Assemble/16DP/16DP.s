	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	LDR R1, constant1; R1=5
	LDR R2, constant2; R2=6
	LDR R3, addr1; 810
	LDR R4, addr2; 820
	LDR R11 addr3;
	LDR R12,addr4; ffffffff
	
	AND R5, R1, #1;   R5=1
	AND R6, R2, R3;   R6=0
	EOR R7, R1, R2;   R7=3
	EOR R8, R1, R1;   R8=0
	ORR R9, R1, R2;   R9=7
	MOV R5, #0;       R5=0
	
	ORR R6, R1, R1;   R6=5
	CMN R2, R11;      R2=6 N=0 Z=0 C=1 V=0
	TST R1, #0;       R1=5 N=0 Z=1
	TEQ R1, #0;       R1=5 N=0 Z=0	
	RSB R7, R7, #7;   R7=4
	ADC R8, R8, #1;   R8=2
	CMP R1, #6;       R1=5 N=1 Z=0 C=0 V=0
	RSC R9, R9, #9;   R9=1
	SBC R5, R1, #2;   R5=2
	MVN R6, #0;       R6=0xffffffff
	BIC R7, R1, #4;   R7=1
	STR R7,[R12];
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
		DCD 0xffffffff;
addr4
		DCD 0x00000830;
constant1
		DCD 0x00000005; 
constant2
		DCD 0x00000006;
constant3 
		DCD 0x00000003;

number0
		DCD 0x00000000;




		END	