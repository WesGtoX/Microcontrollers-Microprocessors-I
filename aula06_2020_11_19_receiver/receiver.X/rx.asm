; Author: Wesley de Oliveira Mendes - 828507

#include <p18F4550.inc>

 CONFIG FOSC = INTOSC_EC ; internal oscillator 
 CONFIG PLLDIV = 4       ; divide por 4 para dar 4MHz no PLL 
 CONFIG FCMEN = OFF      ; no fail safe clock monitor 
 CONFIG IESO = OFF   ; oscillator switchover disabled 
 CONFIG PWRT = ON    ; oscillator power up timer enabled 
 CONFIG BOR = OFF    ; hardware brown out reset 
 CONFIG WDT = OFF    ; watchdog timer disabled 
 CONFIG MCLRE = ON   ; MCLR pin enabled 
 CONFIG LPT1OSC = ON     ; timer1 low power operation 
 CONFIG PBADEN = OFF     ; PortB 0 to 4 digital - not analogue
 CONFIG LVP = OFF    ; low voltage programming disabled 
 CONFIG CCP2MX = OFF     ; portc1 = CCP2 
 CONFIG XINST = OFF  ; bloquear PIC18 extended instructions 
 CONFIG STVREN = ON  ; stack overflow pode causar reset da cpu

; variaveis
dado	; variavel que contem o byte recebido

    org 0x000   ; entrada do vetor de reset
    GOTO Start  ; inicio do programa
    org 0x0020  ; fim do vetor de interrupção e posicao de inicio de programa

Start:
      movlw B'10011000'
      movwf RCSTA
      movlw D'12'
      movwf SPBRG
      BSF   TRISC,RX	; bit set
      CLRF  TRISB
      ; BTFSS PIE1,RCIE
R1:   BTFSS PIR1,RCIF
      BRA   R1
      MOVFF RCREG,PORTB
      CLRF  RCIF
      BRA   R1
      
      GOTO Start
      
     end
