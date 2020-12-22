; *
; * File:   pic_lcd.asm
; * Author:
; *      Quemuel Alves Nassor - 828461
; *      Wesley de Oliveira Mendes - 828507
; *
; * Created on 10 de Dezembro de 2020, 10:06
; *

#include <p18F4550.inc>

 CONFIG FOSC = INTOSC_EC ;  internal oscillator 
 config PLLDIV = 4   ; divide por 4 para dar 4MHz no PLL 
 config FCMEN = OFF  ; no fail safe clock monitor 
 config IESO = OFF   ; oscillator switchover disabled 
 config PWRT = ON    ; oscillator power up timer enabled 
 config BOR = OFF    ; hardware brown out reset 
 config WDT = OFF    ; watchdog timer disabled 
 config MCLRE = ON   ; MCLR pin enabled 
 config LPT1OSC = ON ; timer1 low power operation 
 config PBADEN = OFF ; portB 0to 4 digital - not analogue 
 config LVP = OFF    ; low voltage programming disabled 
 config CCP2MX = OFF ; portc1 = CCP2 
 config XINST = OFF  ; bloquear PIC18 extended instructions 
 config  STVREN = ON ; stack overflow pode causar reset da cpu
	
; CONFIG CP = OFF
; config _PWRTE = ON
; config _WDT = OFF
 
#DEFINE BANCO0 BCF STATUS,RP0
#DEFINE BANCO1 BSF STATUS,RP0
	
;CBLOCK 0X020
TEMPO1 res 1
TEMPO0 res 1
;ENDC
    
 
#DEFINE DISPLAY PORTD
#DEFINE ENABLE PORTE,1
#DEFINE RS PORTE,0
 
    org 0x000  ; entrada do vetor de reset
	GOTO CONFIGU
    ;
    ORG 0X0004
	BCF INTCON,T0IF
	MOVLW 0X1C
	CALL ESCREVE
	RETFIE
    org 0x0008
	goto hi_isr
    ;
    org 0x0018
	goto low_isr
    ;
    org 0x0020  ; posicao de inicio de programa

    
hi_isr
    btfss INTCON, TMR0IF
    goto end_int
    bcf INTCON, TMR0IF; reset na interrupção
    movlw 0xAF
    movwf TMR0L
    movlw 0x3C
    movwf TMR0H
     
    incf counter, f ; incrementa o contador
     
    ;inverte LATD2
    movlw 0x4
    xorwf LATD,F
    
low_isr
    nop
    retfie ;Return e  reset nas interrupções
 
    end 
    ;
    
DELAY_MS:
    MOVFF TEMPO1 DELAY_MSB
    MOVLW .250
    MOVFF TEMPO0 DELAY_MSA
    NOP
    DECFSZ TEMPO0,F
    GOTO DELAY_MSA
    DECFSZ TEMPO1,F
    GOTO DELAY_MSB
    RETURN

ESCREVE:
    MOVWF DISPLAY
    NOP
    BSF ENABLE
    MOVLW .1
    CALL DELAY_MS
    BCF ENABLE
    NOP
    RETURN
    
CONFIGU:
    BANCO1
    MOVLW B'00000000'
    MOVWF  TRISD
    
    MOVLW B'00000000'
    MOVWF TRISE
    
    MOVLW B'10001110' 
    MOVWF ADCON1
    
    MOVLW B'10000111'
    MOVWF OPTION_REG BANCO0
    
    MOVLW B'10000000' 
    MOVWF INTCON
    
    MOVLW B'01000000'
    MOVWF ADCON0
    
    CLRF TEMPO0
    CLRF TEMPO1
    CLRF PORTD
    CLRF PORTE
    MOVLW .1
    CALL DELAY_MS

INICIALIZACAO_DISPLAY:
    BCF RS
    MOVLW 0x38
    CALL ESCREVE
    MOVLW .2
    CALL DELAY_MS
    MOVLW 0X38
    CALL ESCREVE
    MOVLW 0X06
    CALL ESCREVE
    MOVLW 0x0C
    CALL ESCREVE
    MOVLW 0X01
    CALL ESCREVE
    MOVLW .1
    CALL DELAY_MS
    BCF RS
    MOVLW 0X92
    CALL ESCREVE
    BSF RS
    MOVLW 'E'
    CALL ESCREVE
    MOVLW 'N'
    CALL ESCREVE
    MOVLW 'G'
    CALL ESCREVE
    MOVLW 'E'
    CALL ESCREVE
    MOVLW 'N'
    CALL ESCREVE
    MOVLW 'H'
    CALL ESCREVE
    MOVLW 'A'
    CALL ESCREVE
    MOVLW 'R'
    CALL ESCREVE
    MOVLW 'I'
    CALL ESCREVE
    MOVLW 'A'
    CALL ESCREVE
    MOVLW ' '
    CALL ESCREVE
    MOVLW 'E'
    CALL ESCREVE
    MOVLW 'L'
    CALL ESCREVE
    MOVLW 'E'
    CALL ESCREVE
    MOVLW 'T'
    CALL ESCREVE
    MOVLW 'R'
    CALL ESCREVE
    MOVLW 'I'
    CALL ESCREVE
    MOVLW 'C'
    CALL ESCREVE
    MOVLW 'A'
    CALL ESCREVE
    BCF RS
    MOVLW 0XCF
    CALL ESCREVE
    BSF RS
    MOVLW 'S'
    CALL ESCREVE
    MOVLW 'i'
    CALL ESCREVE
    MOVLW 's'
    CALL ESCREVE
    MOVLW 't'
    CALL ESCREVE
    MOVLW 'e'
    CALL ESCREVE
    MOVLW 'm'
    CALL ESCREVE
    MOVLW 'a'
    CALL ESCREVE
    MOVLW 's'
    CALL ESCREVE
    MOVLW ' '
    CALL ESCREVE
    MOVLW 'M'
    CALL ESCREVE
    MOVLW 'i'
    CALL ESCREVE
    MOVLW 'c'
    CALL ESCREVE
    MOVLW 'r'
    CALL ESCREVE
    MOVLW 'o'
    CALL ESCREVE
    MOVLW 'r'
    CALL ESCREVE
    MOVLW 'p'
    CALL ESCREVE
    MOVLW 'o'
    CALL ESCREVE
    MOVLW 'c'
    CALL ESCREVE
    MOVLW 'e'
    CALL ESCREVE
    MOVLW 's'
    CALL ESCREVE
    MOVLW 's'
    CALL ESCREVE
    MOVLW 'a'
    CALL ESCREVE
    MOVLW 'd'
    CALL ESCREVE
    MOVLW 'o'
    CALL ESCREVE
    MOVLW 's'
    CALL ESCREVE
    BCF RS
    BCF INTCON,T0IF
    BSF INTCON,5
    
LOOP:
    GOTO LOOP 
    END    