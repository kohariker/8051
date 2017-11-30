;Rachael Engle
;Edward Koharik
;Anna Pankiwicz
;CompE 3150
;Final Project

org 0000
MOV R0, #40H  ; Input 1
MOV R1, #48H  ; Input 2
MOV R3, #50H  ; Carry Register

; R0 and R1 will be inputs, R3 will be our carry register, R4 will be our length
; R5 will be our counter, R6 will be our temp hold
		MOV R4, #1H
		
		MOV #40, #0AH  ;please manually input bytes
		;MOV #41, #_____
		;MOV #42, #_____
		;MOV #43, #_____
		;MOV #44, #_____
		;MOV #45, #_____
		;MOV #46, #_____
		;MOV #47, #_____
		
		
		MOV #48, #0AH
		;MOV #49, #_____
		;MOV #4A, #_____
		;MOV #4B, #_____
		;MOV #4C, #_____
		;MOV #4D, #_____
		;MOV #4E, #_____
		;MOV #4F, #_____

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
        MOV R7, #8H    ; set counter for eight bits
INTLOOP:   ANL C, 0E0H
        ORL C, 0F0H
        MOV 0F0H, C    ; save Ci into C
        RR A           ; rotate A
        MOV @R1, A	   ; store P in R1
        MOV A, B
        RR A           ; rotate byte
        MOV B, A
        MOV A, @R1     ; reset P
        DJNZ R7, INTLOOP  ; loop for byte
        MOV A, B
        RL A           ; rotate carry string
        MOV @R1, A     ; replace gen with carry in memory

        DEC R0
        DEC R1
        DJNZ R5, CARRY ; repeat for length in bytes
		
		
	MOV R0, #40H
	MOV R1, #48H
	MOV A, R2
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
		
	MOV A, R6
	MOV R5, A
        MOV R0, #48H   ; reset R0
OUT:    JNB TI, $
        CLR TI
        MOV A, @R0
        MOV C, P
        MOV TB8, C     ; set parity
        MOV SBUF, A    ; output result
        INC R0
        DJNZ R5, OUT
		
	MOV SBUF, #00H ; make sure SBUF cleared everything
        END
