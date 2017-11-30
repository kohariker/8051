;Rachael Engle
;Edward Koharik
;Anna Pankiwicz
;CompE 3150
;Final Project

;org 0000
        MOV 40H, #00H   ; Input A
        MOV 41H, #00H
        MOV 42H, #00H
        MOV 43H, #00H
        MOV 44H, #00H
        MOV 45H, #00H
        MOV 46H, #00H
        MOV 47H, #00H

        MOV 48H, #00H  ; Input B
        MOV 49H, #00H
        MOV 4AH, #00H
        MOV 4BH, #00H
        MOV 4CH, #00H
        MOV 4DH, #00H
        MOV 4EH, #00H
        MOV 4FH, #00H

        MOV R2,  #8H   ; Length of longest operand in bytes

        MOV R0, #40H
        MOV R1, #48H
        MOV A, R2
        MOV R5, A      ; length of operands stored in R2

SETUP:  MOV SCON, #10000010B
        MOV TMOD, #00010000B
        MOV TL1, #00H  ; start timer at 0
        MOV TH1, #00H  ; start timer at 0

INPUTA: JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, @R0
        MOV C, P
        MOV TB8, C     ; set odd parity bit
        MOV SBUF, A    ; output byte of A
        INC R0         ; move to next byte
        DJNZ R5, INPUTA
        MOV R0, #40H   ; reset to beginning of A

        MOV A, R2      ; reset counter
        MOV R5, A
INPUTB: JNB TI, $      ; wait until ready to transmit
        CLR TI
        MOV A, @R1
        MOV C, P
        MOV TB8, C     ; set odd parity bit
        MOV SBUF, A    ; output byte of B
        INC R1
        DJNZ R5, INPUTB
        MOV R1, #48H   ; reset to beginning of B

        SETB TR1       ; start timer
        MOV A, R2      ; init counter
        MOV R5, A
LOAD:   MOV A, @R0     ; temp hold for byte of R6 data
        MOV R4, A
        MOV A, @R0
        XRL A, @R1     ; propagate
        MOV @R0, A

        MOV A, @R1
        ANL A, R4      ; generate
        MOV @R1, A
        INC R0         ; move to next bit of P
        INC R1         ; move to next bit of G
        DJNZ R5, LOAD

        MOV A, R2      ; reset R5
        MOV R5, A
        CLR C          ; C will be used as Ci in boolean equation
        MOV A, R2
        DEC A
        ADD A, #40H
        MOV R0, A      ; point at least significant byte
        MOV A, R2
        DEC A
        ADD A, #48H
        MOV R1, A      ; point at least significant byte


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

        MOV A, R2
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
        
FLUSH:  MOV A, #0FFH
        MOV C, P
        MOV TB8, C
        MOV SBUF, A    ; output dummy byte to flush output
        END
