;Rachael Engle
;Edward Koharik
;Anna Pankiwicz
;CompE 3150
;Final Project

;org 0000
MOV R0, #40H  ; Input 1
MOV R1, #48H  ; Input 2
MOV R3, #50H  ; Carry Register

; R0 and R1 will be inputs, R3 will be our carry register, R4 will be our length
; R5 will be our counter, will be our temp hold
		
	MOV R4, #1H
		
	MOV 40H, #0AH  ;please manually input bytes
	;MOV 41H, #_____
	;MOV 42H, #_____
	;MOV 43H, #_____
	;MOV 44H, #_____
	;MOV 45H, #_____
	;MOV 46H, #_____
	;MOV 47H, #_____
		
		
	MOV 48H, #0AH
	;MOV 49H, #_____
	;MOV 4AH, #_____
	;MOV 4BH, #_____
	;MOV 4CH, #_____
	;MOV 4DH, #_____
	;MOV 4EH, #_____
	;MOV 4FH, #_____

	MOV TMOD, #00010000B ;Setup for timer and output
	MOV TL1, #00H
	MOV TH1, #00H
	MOV SCON, #10000010B
	
	MOV A, R4
	MOV R5, A
PRINT:	JNB TI, $
	CLR TI
	MOV A, @R0
	MOV C, P
	MOV TB8, C
	MOV SBUF, A
	INC R0         ; move to next byte
        DJNZ R5, PRINT
		
        MOV R0, #40H   ; reset to beginning of A

        MOV A, R4      ; reset counter
        MOV R5, A
		
PRINT2: JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, @R1
        MOV C, P
        MOV TB8, C     ; set odd parity bit
        MOV SBUF, A    ; output byte of B
        INC R1
        DJNZ R5, PRINT2
		
        MOV R1, #48H   ; reset to beginning of B

		
	MOV A, R4
	MOV R5, A
	MOV SBUF, #00H
	SETB TR1
	
INPUT:  MOV A, @R0  ; hold each byte of R0
	MOV R6, A
		
	MOV A, @R0
        XRL A, @R1 ; propagate
	MOV @R0, A
		
	MOV A, @R1
        ANL A, R6  ; generate
	MOV @R1, A
        INC R0
        INC R1
        DJNZ R5, INPUT

        MOV A, R4
	MOV R5, A ; reset counter
        CLR C
	MOV A, R4
	DEC A
        ADD A, #40H
        MOV R0, A  
        MOV A, R2
        DEC A
        ADD A, #48H
        MOV R1, A

CARRY:  MOV B, @R1
        MOV A, @R0
        MOV R6, #8H    ; set counter for eight bits
	MOV 0D6H, C
INTLOOP: ANL C, 0E0H
        ORL C, 0F0H
        MOV 0F0H, C    ; save Ci into C
        RR A           ; rotate A
        MOV @R1, A	   ; store P in R1
        MOV A, B
        RR A           ; rotate byte
        MOV B, A
        MOV A, @R1     ; reset P
        DJNZ R6, INTLOOP  ; loop for byte
	MOV 0D5H, C
	CLR C
	RLC A		; rotate carry string
	MOV C, 0D5H
	JNB 0D6H, JUMP
	INC A
JUMP:	MOV @R1, A

        DEC R0
        DEC R1
        DJNZ R5, CARRY ; repeat for length in bytes
		
		
	MOV R0, #40H
	MOV R1, #48H
	MOV A, R4
	MOV R5, A
SUM:    MOV A, @R0
        XRL A, @R1	;start addition
        MOV @R0, A     
        INC R0         ; move down a bit
        INC R1
        DJNZ R5, SUM
		
        CLR TR1        ; stop timing

	JNB TI, $
        CLR TI
        MOV A, TH1
        MOV C, P
        MOV TB8, C     ; set parity
        MOV SBUF, A    ; send high byte through serial
        JNB TI, $      ; wait
        CLR TI
		
        MOV A, TL1
        MOV C, P       ; set parity
        MOV TB8, C
        MOV SBUF, A    ; send low byte
	MOV SBUF, #00H
		
	MOV A, R4
	MOV R5, A
        MOV R0, #40H   ; reset R0
DONE:   JNB TI, $
        CLR TI
        MOV A, @R0
        MOV C, P
        MOV TB8, C     ; set parity
        MOV SBUF, A    ; output result
        INC R0
        DJNZ R5, DONE
		
	MOV SBUF, #00H ; make sure SBUF cleared everything
        END
