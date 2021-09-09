 /**
  ******************************************************************************
  * @Project LED8x32     
  * @author  Quoc Bao, Dao Thi
  * @date    31-05-2021
  *******************************************************************************/
;---------CHI THI VA GAN BIEN-----------	
	STATE 		EQU   R2  	
	DEMTG  		EQU	  R3
	ONOFFFLAG   BIT P3.7
	CHONLED		EQU 64H
	QUETHANG	EQU 65H
	DICH		EQU 66H
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			ORG 00H
			LJMP SETUP
			ORG 003H
			LJMP ISREX0
			ORG 00BH
			LJMP ISRT0

;-----------THIET LAP----------------------
			ORG 30H
			;--------
SETUP:		MOV 	TMOD,	#01H
			MOV 	DEMTG,	#20
			MOV 	IE,		#8BH
			SETB	IT0
			MOV		A,		#0
			MOV 	R1,		#64H		 					;CHONLED
			MOV 	R0,		#65H							;QUETHANG
			MOV 	QUETHANG,#0FFH
			MOV 	CHONLED,#01H
			MOV 	R4,		#01								 ; KHI BAT DAU CHAY, SE CHAY HIEU UNG 1
			CLR 	P3.6							 ; TAT LOA
			JMP 	KOHIEUUNG

;-----------CHON MODE------------------------

MODE:		PUSH 	04H	
			DJNZ	R4,		HIEUUNG1
			POP		04H
			SETB	P3.6
			ACALL 	DELAY250MS
			CLR 	P3.6
			JMP 	KOHIEUUNG
HIEUUNG1:	DJNZ 	R4,		HIEUUNG2
			POP 	04H
			SETB	P3.6
			ACALL 	DELAY250MS
			CLR		P3.6
			JMP		NHAPNHAY
HIEUUNG2:	DJNZ 	R4,		MODE
			POP 	04H
			SETB	P3.6
			ACALL	DELAY250MS
			CLR 	P3.6
			JMP 	CHAY

;----------KHONG HIEU UNG ------------------------
KOHIEUUNG:	JBC 	F0, MODE							; CO F0 LA CO KIEM TRA CO SU KIEN BAM NUT CHUA	
  			PUSH	ACC
			MOV 	DICH, #0							; GIU NGUYEN, KHONG DICH VIEC QUET COT DI
			CALL	HIENTHI
			POP 	ACC
			JMP 	KOHIEUUNG
			
;-----------NHAP NHAY----------------------------
NHAPNHAY:	SETB	TF0
			JBC  	F0, 			MODE		  				; CO F0 LA CO KIEM TRA CO SU KIEN BAM NUT CHUA
			JB 		ONOFFFLAG, 		$-3
  			ACALL 	HIENTHI
		   	JMP 	NHAPNHAY

;-----------CHAYTUTRAISANGPHAI----------------------
CHAY:	
			SETB	TF0			
			MOV 	DICH, 	#0
QUAYLAI:	JBC 	F0,				MODE
			ACALL 	HIENTHI
			JB 		ONOFFFLAG, 		QUAYLAI
			INC 	DICH
			MOV		A,				DICH
			SETB 	ONOFFFLAG
			CJNE 	A,		#40, 	QUAYLAI			
			JMP 	CHAY
		
;-----------HIEN THI--------------------------------
HIENTHI:	MOV	A,#0
HIENTHI1L:	PUSH ACC
			;---------QUET COT-----
			MOV DPTR,#TABLECOT
			MOVC A,@A+DPTR
			MOV	P0,A
			;---------QUET HANG------
			MOV P1, CHONLED
			MOV DPTR,#TABLEHANG
			INC QUETHANG
			MOV A,QUETHANG
			ADD A,DICH
			MOVC  A,@A+DPTR
			CJNE @R0,#32,SKIP			  ;QUET 32 HANG TU TRAI SANG PHAI
			MOV  @R0,DICH				  ;DICH SAU KHI DA QUET HET 32 HANG
SKIP:		MOV P2,A
			MOV P1,#00H
			ACALL DELAY2MS
			POP ACC
			INC A
			CJNE A,#08H,HIENTHI1L
			;----- TAT HET TAT CA CAC LED
			MOV	P1,CHONLED
			MOV P2,#0FFH
			MOV P1,#00H
			MOV A,CHONLED
			RL A
			MOV CHONLED,A
			MOV A,#0
			CJNE @R1,#10H,HIENTHI1L
			;-------CHON LAI LUC DAU-------

			MOV QUETHANG,#0FFH
			MOV CHONLED,#01H
			RET
			;------------------------------
DELAY2MS:	MOV R7,#2
LAP1:		MOV R6,#250
			DJNZ R6,$
			DJNZ R7,LAP1
			RET	
			;-------------------------------
DELAY250MS:	MOV R7,#1
X:			MOV	R6,#250
XX:			MOV R5,#250
			DJNZ R5,$
			DJNZ R6,XX
			DJNZ R7,X
			RET
			;--------- NGAT NGOAI 0 DE CHECK NUT BAM
ISREX0:		SETB F0
			INC R4
			CJNE R4,#4,EXIT
			MOV R4,#1
EXIT: 		RETI
			;---------TIMER0 TAO DELAY 1S----------	
ISRT0:		CLR TR0
			CLR TF0
			MOV TH0,#HIGH(-50000)
			MOV TL0,#LOW(-50000)
			DJNZ DEMTG,NEXT
			MOV DEMTG,#20 
			CPL ONOFFFLAG
NEXT:		SETB TR0
			RETI
			
TABLECOT:	DB  01H, 02H, 04H, 08H, 10H, 20H, 40H, 80H
TABLEHANG:	DB 	0FFH,0FFH,001H,07DH,07DH,083H,0FFH,0FFH	
			DB  0FFH,0FFH,001H,0F7H,0F7H,001H,0FFH,0FFH
			DB  0FFH,0FFH,001H,06DH,06DH,093H,0FFH,0FFH
			DB  0FFH,0FFH,001H,0EFH,0D7H,039H,0FFH,0FFH
			db  0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
			DB 	0FFH,0FFH,001H,07DH,07DH,083H,0FFH,0FFH	
			DB  0FFH,0FFH,001H,0F7H,0F7H,001H,0FFH,0FFH
			DB  0FFH,0FFH,001H,06DH,06DH,093H,0FFH,0FFH
			DB  0FFH,0FFH,001H,0EFH,0D7H,039H,0FFH,0FFH		
			END
