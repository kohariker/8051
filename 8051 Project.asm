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
        MOV R4, #8H    ; set counter for 8 rotations
        MOV 0D6H, C    ; store carry-in
BITE:   ANL C, 0E0H    ; intermediate = Ci AND P(i+1)
        ORL C, 0F0H
        MOV 0F0H, C    ; save Ci into C as well as R3.0
        RR A           ; rotate P byte
        MOV @R1, A     ; store P byte in mem
        MOV A, B       ; move G/C to A for rotation
        RR A           ; rotate G/C byte
        MOV B, A       ; replace byte in R3
        MOV A, @R1     ; reload P from mem
        DJNZ R4, BITE  ; repeat for whole byte
        MOV A, B
        MOV 0D5H, C    ; store carry-out
        CLR C
        RLC A          ; rotate C/G string to align carrys over correct bits
        MOV C, 0D5H    ; restore carry-out
        JNB 0D6H, NOINC
        INC A          ; increment if there was a carry-in
NOINC   MOV @R1, A     ; replace C/G in memory

        DEC R0
        DEC R1
        DJNZ R5, CARRY
		
		
        MOV R0, #40H   ; return to beginning of P
        MOV R1, #48H   ; return to beginning of C/G
        MOV A, R2
        MOV R5, A
SUM:    MOV A, @R0
        XRL A, @R1
        MOV @R0, A     ; compute final sum
        INC R0         ; move to next bit of P
        INC R1         ; move to next bit of Carry string
        DJNZ R5, SUM
        CLR TR1        ; stop timer

TIME:   JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, TH1
        MOV C, P
        MOV TB8, C     ; set odd parity bit
        MOV SBUF, A    ; output high byte of time
        JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, TL1
        MOV C, P       ; set odd parity bit
        MOV TB8, C
        MOV SBUF, A    ; output low byte of time
		
        MOV A, R4
        MOV R5, A
        MOV R0, #40H   ; reset R0 to beginning of result string
OUT:    JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, @R0
        MOV C, P
        MOV TB8, C     ; set odd parity bit
        MOV SBUF, A    ; output byte of result
        INC R0
        DJNZ R5, OUT
		
	MOV SBUF, #00H ; make sure SBUF cleared everything
        END
