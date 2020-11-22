;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;   AVALIACAO PARCIAL - 2020-II                 ;
;   ENGENHARIA DA COMPUTACAO - MICC E MICP I    ;
;   WESLEY DE OLIVEIRA MENDES - 828507          ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <p18F4550.inc>

 CONFIG FOSC = INTOSC_EC    ; Internal oscillator 
 config PLLDIV = 4	    ; Divide por 4 para dar 4MHz no PLL 
 config FCMEN = OFF	    ; No fail safe clock monitor 
 config IESO = OFF	    ; Oscillator switchover disabled 
 config PWRT = ON	    ; Oscillator power up timer enabled 
 config BOR = OFF	    ; Hardware brown out reset 
 config WDT = OFF	    ; Watchdog timer disabled 
 config MCLRE = ON	    ; MCLR pin enabled 
 config LPT1OSC = ON	    ; Timer1 low power operation 
 config PBADEN = OFF	    ; PortB 0to 4 digital - not analogue 
 config LVP = OFF	    ; Low voltage programming disabled 
 config CCP2MX = OFF	    ; Portc1 = CCP2 
 config XINST = OFF	    ; Bloquear PIC18 extended instructions 
 config STVREN = ON	    ; Stack overflow pode causar reset da cpu
	
Delay1	  equ 5		    ; Primeiro delay
Delay2	  equ 2		    ; Segundo delay para criar um loop de tempo
switch	  equ 0		    ; PUSH BUTTON INPUT RA0
btnTimer  equ 2		    ; PUSH BUTTON INPUT RA2
LAMP	  equ 4		    ; LAMP OUTPUT RA4

	org 0x000	    ; Entrada do vetor de reset
	goto Start
	
	org 0x0020	    ; Posicao de inicio de programa

Start:
    movlw B'01000000'	    ; Ajustar frequencia do clock em FOSC = 1MHz
    movwf OSCCON
    
    MOVLW 0Fh		    ; Configura A/D
    MOVWF ADCON1	    ; Para uso como portas digitais
    MOVLW 07h		    ; Configura os comparadores 
    MOVWF CMCON		    ; Para uso como entrada digital
    MOVLW 0AFh		    ; Programa a direção dos dados
    MOVWF TRISA		    ; Usando RA<3:0> como entrada e RA<5:4> como saida
    
input:
    BTFSS PORTA, switch	    ; Espera pressionar o botao de interruptor
    goto timer		    ; Se nao foi pressionado volta se nao segue
    goto turnon		    ; Vai para turnon

timer:
    BTFSS PORTA, btnTimer   ; Espera pressionar o botao de timer
    goto input		    ; Se nao foi pressionado volta se nao segue
    goto timerlamp	    ; Vai para timerlamp e inicia o timer com LAMP ativada
    
turnon:
    BTG PORTA, LAMP	    ; Inverte o estado logico de LAMP
    goto input		    ; Se nao foi pressionado volta se nao segue

timerlamp:
    BSF PORTA, LAMP	    ; Ativa a porta LAMP
    goto delay_0	    ; Inicia o delay (loop)

delay_0:
    DECFSZ Delay1, 1	    ; Decrementa o Delay1 de 1, vai para endloop se Delay1 = 0
    goto delay_1	    ; Vai para delay_1 e inicia decremento do Delay2
    goto endloop	    ; Vai para endloop para encerrar o delay (timer) e desativar a LAMP

delay_1:
    DECFSZ Delay2, 1	    ; Decrementa o Delay2 de 1, vai para delay_0 se Delay2 = 0
    goto delay_1	    ; Gera um loop até o Delay2 ser 0
    goto delay_0	    ; Delay2 = 0, volta para delay_0
    
endloop:
    BTG PORTA, LAMP	    ; Desativa a porta LAMP
    goto Start		    ; Vai para Start
    
    end
