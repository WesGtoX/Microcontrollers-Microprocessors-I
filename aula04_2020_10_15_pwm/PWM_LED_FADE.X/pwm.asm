;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Copyright (c) 2013 Manolis Agkopian		    ;
	;See the file LICENCE for copying permission.	    ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; THE FOLLOWING STEPS SHOULD BE TAKEN WHEN CONFIGURING THE CCP MODULE FOR PWM OPERATION: ;
	;                                                                                        ;
	; 1. SET THE PWM PERIOD BY WRITING TO THE PR2 REGISTER.                                  ;
	; 2. SET THE PWM DUTY CYCLE BY WRITING TO THE CCPR1L REGISTER AND CCP1CON<5:4> BITS.     ;
	; 3. MAKE THE CCP1 PIN AN OUTPUT BY CLEARING THE TRISC<2> BIT.                           ;
	; 4. SET THE TMR2 PRESCALE VALUE AND ENABLE TIMER2 BY WRITING TO T2CON.                  ;
	; 5. CONFIGURE THE CCP1 MODULE FOR PWM OPERATION.                                        ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
#include <p18F4550.inc>

	                ; nomes deixados originais para facilitar
			; a localização no datasheet
 CONFIG FOSC = INTOSC_EC ;  internal oscillator 
 config PLLDIV = 4   ; divide por 5 para dar 4MHz no PLL 
 config FCMEN = OFF  ; no fail safe clock monitor 
 config IESO = OFF   ; oscillator switchover disabled 
 config PWRT = ON    ; oscillator power up timer enabled 
 config BOR = OFF    ; hardware brown out reset 
 config WDT = OFF    ; watchdog timer disabled 
 config MCLRE = ON   ; MCLR pin enabled 
 config LPT1OSC = ON ; timer1 low power operation 
 config PBADEN = OFF ; portB para digital - não analogico 
 config LVP = OFF    ; low voltage programming disabled 
 config CCP2MX = OFF ; portc1 = CCP2 
 config XINST = OFF  ; bloquear PIC18 extended instructions 
 config  STVREN = ON ; stack overflow pode causar reset da cpu
 ;
D1 res 1;
D2 res 1;
FADE_STATE equ 0x00; ;IF = 0x00 INCREMENT CCPR1L ELSE DECREMENT CCPR1L
;	
	ORG 0x00
	goto INIT
;	
	org 0x0020
INIT:   ; FUNÇÕES DEIXADAS NOS NOMES EM INGLES PARA REFERENCIAR NO DATASHEET
        ;
	;PERIODO DO PWM = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE VALUE) ;PR2 = TMR2 
	;PERIOD REGISTER, TOSC = PIC CLOCK PERIOD (FOSC = 1 / TOSC)
	;PWM DUTY CYCLE = (CCPR1L:CCP1CON<5:4>) * TOSC * (TMR2 PRESCALE VALUE)
	
	;;;SETA FREQUENCIA DO PWM ;
	banksel 1 ;
	MOVLW D'128' ;SETA PR2 PARA 128 DECIMAL ENTÃO O PERIODO DO PWM 
	MOVWF PR2    ;SERA = 2064uS => FREQUENCIA DO PWM = 484Hz
	banksel 0 ;
	;;;SETA O INICIO DO CICLO DE PWM;
	CLRF CCPR1L
	MOVLW B'00001100' ;SETA MODO PWM, BITS 5 E 4 SÃO OS DOIS LSBs 
	MOVWF CCP1CON  ;DO REGISTRADOR DE DUTY CYCLE DE 10 BITS (CCPR1L:CCP1CON<5:4>)
	;SETA O PINO DE PW COMO OUTPUR;
	banksel 1; 
	BCF TRISC, 2 ;SETA RC2 COMO OUTPUT, PARA USAR COMO  PWM
	banksel 0; 
	
	;;;SET TIMER 2 PRESCALE ;
	;PRESCALE = 16 ENTÃO O PERIODO DO PWM = 2064uS => FREQUENCIA DO PWM = 484Hz
	MOVLW B'00000010'
	MOVWF T2CON
	;;;CLEAR TIMER 2 ;;
	CLRF TMR2
	;;;ENABLE TIMER 2 ;
	BSF T2CON, TMR2ON
	CLRF FADE_STATE

MAIN:
	CALL DELAY
	MOVLW 0x00
	IORWF FADE_STATE, W
	BTFSS STATUS, Z ;Se FADE_STATE = 0 Gvai para INC_CC
	GOTO DEC_CC ;Senão vai para  DEC_CC
INC_CC:
	INCFSZ CCPR1L ;INCREMENTA CCPR1L
	GOTO MAIN
	GOTO CH_ST_0 ;Se tivermos um OVERFLOW vai para  CH_ST
DEC_CC:
	DECFSZ CCPR1L ;DECREMENTA CCPR1L
	GOTO MAIN
	;Se tivermos um OVERFLOW vai para  CH_ST
CH_ST:
	COMF FADE_STATE, F ;inverte o estado do bit 
	INCFSZ CCPR1L
	GOTO MAIN
CH_ST_0:
	COMF FADE_STATE, F ;inverte o estado do bit 
	DECFSZ CCPR1L
	GOTO MAIN
DELAY:
	;9993 ciclos
	MOVLW	0xCE
	MOVWF	D1
	MOVLW	0x08
	MOVWF	D2
DELAY_0
	DECFSZ	D1, F
	GOTO	DEL_0
	DECFSZ	D2, F
DEL_0	GOTO	DELAY_0
	NOP
	;4 cilcos - incluindo o call
	MOVLW	0x00
	MOVWF	D1
	MOVLW	0x00
	MOVWF	D2
	RETURN
;
	END
