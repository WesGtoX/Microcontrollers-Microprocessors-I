;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    PBL - LED liga/desliga via push button
;    MIC-I 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <p18F4550.inc>

	                ; nomes deixados originais para facilitar
			; a localiza??o no datasheet
 CONFIG FOSC = INTOSC_EC ;  internal oscillator 
 config PLLDIV = 4   ; divide por 5 para dar 4MHz no PLL 
 config FCMEN = OFF  ; no fail safe clock monitor 
 config IESO = OFF   ; oscillator switchover disabled 
 config PWRT = ON    ; oscillator power up timer enabled 
 config BOR = OFF    ; hardware brown out reset 
 config WDT = OFF    ; watchdog timer disabled 
 config MCLRE = ON   ; MCLR pin enabled 
 config LPT1OSC = ON ; timer1 low power operation 
 config PBADEN = OFF ; portB para digital - n?o analogico 
 config LVP = OFF    ; low voltage programming disabled 
 config CCP2MX = OFF ; portc1 = CCP2 
 config XINST = OFF  ; bloquear PIC18 extended instructions 
 config  STVREN = ON ; stack overflow pode causar reset da cpu
	
Delay1  equ  127
botao   equ 0   ;PUSH BUTTON INPUT RA0
LED     equ 4   ;LED OUTPUT RA4 
 
	org 0x000  ; entrada do vetor de reset
	goto Start
	
	org 0x0020  ; posicao de inicio de programa

Start:
    MOVLW 10h
    MOVWF STKPTR
    
    CLRF PORTA ; Initialize PORTA limpando os data latches
    MOVLW 0Fh ; Configura A/D
    MOVWF ADCON1 ; para uso como portas digitais
    MOVLW 07h ; Configura os comparadores 
    MOVWF CMCON ; para uso como entrada digital
    MOVLW 0CFh ; programa a dire??o dos dados
    MOVWF TRISA ; Usando RA<3:0> como entrada e RA<5:4> como saida
    
entrada:
    BTFSS PORTA,botao ;espera pressionar o botao
    goto entrada      ; se n?o apertou, volta se apertou segue...
    call pisca
    goto entrada
;    
; sub rotina de picar o led e verifica botao    
;
    
pisca:
    DECFSZ Delay1,1 ;Decrementa o Delay1 de 1, vai para proxima instru??o se Delay1 = 0 
    goto pisca 
    BTG  PORTA,LED    ; inverte o estado logico do led
    BTFSS PORTA,botao ;espera pressionar o botao
    goto pisca
    return
    ;
    end
    