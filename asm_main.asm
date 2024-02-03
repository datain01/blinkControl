.thumb

.text			; Puts code in ROM

; Port 4 Registers
P4IN    	.word	0x40004C21		; Port 4 Input
P4OUT   	.word	0x40004C23		; Port 4 Output
P4DIR   	.word	0x40004C25		; Port 4 Direction
P4REN   	.word	0x40004C27		; Port 4 Resistor Enable
P4DS    	.word	0x40004C29		; Port 4 Drive Strength
P4SEL0  	.word	0x40004C2B		; Port 4 Select 0
P4SEL1  	.word	0x40004C2D		; Port 4 Select 1

; Port 5 Registers
P5IN    	.word	0x40004C40		; Port 5 Input
P5OUT   	.word	0x40004C42		; Port 5 Output
P5DIR   	.word	0x40004C44		; Port 5 Direction
P5REN   	.word	0x40004C46		; Port 5 Resistor Enable
P5DS    	.word	0x40004C48		; Port 5 Drive Strength
P5SEL0  	.word	0x40004C4A		; Port 5 Select 0
P5SEL1  	.word	0x40004C4C		; Port 5 Select 1

			.global asm_main
			.thumbfunc asm_main

asm_main:
    BL   GPIO_Init
    LDR  R1, P4OUT
    LDR  R2, P5IN

loop:
	BL   SW_Input     ; Check the switch input
    CMP  R0, #0x01    ; Check if switch is pressed
    BNE  TOGGLE_LED   ; If not pressed, toggle the LED
    B   LED_ON       ; If pressed, turn the LED ON
    B    loop

LED_ON:
    LDR  R3, P5OUT
    MOV  R3, #0x01    ; LED ON (P1.0 = 1)
    STRB R3, [R1]
    BL   DELAY_62_5ms   ; Add this line for 100ms delay
    B    loop

TOGGLE_LED:
    LDRB R3, [R1]
    EOR  R3, R3, #0x01
    STRB R3, [R1]
    BL   DELAY_62_5ms
    B    loop


DELAY_62_5ms:
    PUSH    {R4-R5}
    MOV     R4, #195

DELAY_OUTER:
    MOV     R5, #1000

DELAY_INNER:
    SUBS    R5, R5, #1
    BNE    	DELAY_INNER
    SUBS    R4, R4, #1
    BNE     DELAY_OUTER
    POP     {R4-R5}
    BX      LR

GPIO_Init:
    PUSH    {R0-R1}

    ; Set P4.0
	LDR     R1, P4SEL0
	LDRB    R0, [R1]
	BIC     R0, R0, #0x01  ; Clear bits for P1.4 and P1.0 0001 0001
	STRB    R0, [R1]

	; Set P4.0
	LDR     R1, P4SEL1
	LDRB    R0, [R1]
	BIC     R0, R0, #0x01
	STRB    R0, [R1]

	; Initialize P4.0
	LDR     R1, P4DIR
	LDRB    R0, [R1]
	ORR     R0, R0, #0x01
	STRB    R0, [R1]

	;Set P5.0
	LDR     R1, P5SEL0
	LDRB    R0, [R1]
	BIC     R0, R0, #0x01
	STRB    R0, [R1]

	; Set P5.0
	LDR     R1, P5SEL1
	LDRB    R0, [R1]
	BIC     R0, R0, #0x01
	STRB    R0, [R1]

	; Initialize P5.0 output
	LDR     R1, P5DIR
	LDRB    R0, [R1]
	BIC     R0, R0, #0x01           ; Set P5.0 as output (1) 0000 0001
	STRB    R0, [R1]


    POP     {R0-R1}
    BX      LR

SW_Input:
    PUSH    {LR}

    LDRB    R0, [R2] ; load value of P1IN to R0
    ;LSR		R0, #0x04				; Shift P1.4 to the LSB
	BIC		R0, R0, #0xFE           ; Clear upper 7 bits for P1.1

    POP     {LR}
    BX      LR
.end
