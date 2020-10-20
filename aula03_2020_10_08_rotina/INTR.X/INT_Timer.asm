;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    PBL - 3 Interrupção do timer - solução para os dois leds
;    MIC- I - 2018
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	
Delay1 res 1;reserva 1 byte 
Delay2 res 1;reserva 1 byte 
 
	org 0x000  ; entrada do vetor de reset
	goto Main
	;
	org 0x0008
        goto hi_isr
        ;
	org 0x0018
        goto low_isr
	;
	org 0x0020  ; posicao de inicio de programa
        ;
Main:
counter  equ  0x10 ; variavel de contagem colocada na RAM em 10h
    clrf counter ; clear no contador
     
    ; configura LATD0-LATD3 como outputs e RD4-RD7 como inputs
    banksel TRISD
    movlw 0xf0
    movwf TRISD
     
    clrf LATD ; desliga todos os pinos de LATD 
    bsf LATD,3 ; liga LATD3
     
    ; Ajusta a frequencia de clock
    ; Ajuste em Fosc = 8MHz, o que resulta em  T = 0.5us
    movlw B'01110000'
    movwf OSCCON 
 
    bcf INTCON, GIE ;Desliga global interrupts
    bcf T0CON, TMR0ON; Desliga timer 0       
    bsf INTCON, TMR0IE;Liga TIMER0 interupt
      
    ;Ajusta 1:2 prescaler para que TMR0 SFR seja incrementado em 2T = 1 us
    bsf T0CON,0
    bsf T0CON,1
    bsf T0CON,2
     
    bcf T0CON, T0CS; Usar internal instruction cycle clock
    bcf T0CON, T08BIT; Usar modo 16 bits
    bcf T0CON, PSA; Liga o prescaler
     
    ; Agora o timer0 overflow seja chaveado rapidamente
    ; 
    movlw 0xFF
    movwf TMR0L
    movlw 0xFF
    movwf TMR0H
     
    bsf INTCON2, TMR0IP; ; Ajusta o timer0 interrupt como sendo high priority
    bsf INTCON, GIE ;Liga global interrupts  
    bsf T0CON, TMR0ON; Liga timer 0    
     
loop   
    	BTG PORTD,RD1 ;inverte o estado da PORT D PINO 1 (20)
Delay:
	DECFSZ    Delay1,1 ;Decrementa o Delay1 de 1, vai para proxima instrução se Delay1 = 0 
	GOTO Delay
	DECFSZ	  Delay2,1
	GOTO Delay
;	GOTO loop
    goto loop   
 
    ;-----High Priority Interrupt Service Routine ---------------------------------------------
    org 0x0200 
hi_isr
    btfss INTCON, TMR0IF
    goto end_int
    bcf INTCON, TMR0IF; reset na interrupção
    movlw 0x7D
    movwf TMR0L
    movlw 0x00
    movwf TMR0H
     
    incf counter, f ; incrementa o contador
     
    ;inverte LATD2
    movlw 0x4
    xorwf LATD,F
 
end_int:
    retfie ;return e  reset nas interrupções
  
 
    ;-----Low Priority Interrupt Service Routine  ---------------------------------------------   
    org 0x0300 
low_isr
    nop
    retfie ;Return e  reset nas interrupções
 
    end 
    ;
