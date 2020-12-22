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
dado	; variavel que contam o byte recebido

    org 0x000   ; entrada do vetor de reset
    GOTO Start  ; inicio do programa
    org 0x0020  ; fim do vetor de interrupção e posicao de inicio de programa
    
    ; baud rate(br) = Fosc / 16(n + 1)
    ; 16(n + 1) = Fosc / br
    ; n + 1 = Fosc / (br * 16)
    ; n = Fosc / (br * 16) - 1
    ; n = 52
Start:
      banksel STATUS
      bsf STATUS,0	; vai para o banco 1
      movlw D'12'	; baud rate 9600 bps
      movwf SPBRG
      
      ; configura o TX
      movlw B'00100100'
      movwf TXSTA
      banksel STATUS
      bcf STATUS,0	; volta para o banco 0
      
      ; configura o receptor RX
      movlw B'10000000'
      movwf RCSTA
      
      ; caractere a ser transmitido
      movlw 0x41	; transmite, letra A maiuscula
      movwf dado
main:
      movf dado,W
      movwf TXREG  ; transmite
      goto envia
      goto main
envia:
      btfss TXSTA,TRMT
      goto envia
      banksel STATUS
      bcf STATUS,0
      return
      
      
        GOTO Start
        end
