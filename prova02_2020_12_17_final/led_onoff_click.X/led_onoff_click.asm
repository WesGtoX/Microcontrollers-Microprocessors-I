;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;   AVALIACAO FINAL - 2020-II                   ;
;   ENGENHARIA DA COMPUTACAO - MICC E MICP I    ;
;   WESLEY DE OLIVEIRA MENDES - 828507          ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
#include <p18F4550.inc>

 CONFIG FOSC = INTOSC_EC    ; internal oscillator 
 CONFIG PLLDIV = 4	    ; divide por 4 para dar 4MHz no PLL 
 CONFIG FCMEN = OFF	    ; no fail safe clock monitor 
 CONFIG IESO = OFF	    ; oscillator switchover disabled 
 CONFIG PWRT = ON	    ; oscillator power up timer enabled 
 CONFIG BOR = OFF	    ; hardware brown out reset 
 CONFIG WDT = OFF	    ; watchdog timer disabled 
 CONFIG MCLRE = ON	    ; MCLR pin enabled 
 CONFIG LPT1OSC = ON	    ; timer1 low power operation 
 CONFIG PBADEN = OFF	    ; PortB 0 to 4 digital - not analogue
 CONFIG LVP = OFF	    ; low voltage programming disabled 
 CONFIG CCP2MX = OFF	    ; portc1 = CCP2 
 CONFIG XINST = OFF	    ; bloquear PIC18 extended instructions 
 CONFIG STVREN = ON	    ; stack overflow pode causar reset da cpu

; Variaveis
BTNON equ 0		    ; Botao ON
BTNOFF equ 1		    ; Botao OFF
LED equ 0		    ; LED RC4
Delay1 res 1		    ; Variavel de delay

      org 0x000		    ; Entrada do vetor de reset
      goto Start
      org 0x0020	    ; Posicao de inicio de programa

Start:
      ; Configura PORTA A
      BANKSEL TRISA	    ; Set registrar port A
      CLRF PORTA	    ; Limpa a pora A
      BSF TRISA,BTNON	    ; Set botao on input
      BSF TRISA,BTNOFF      ; Set botao off input
      movwf TRISA
      
      ; Conversor Digital
      movlw 0Fh		    ; Habilita 00001111 no registrador work
      movwf ADCON1	    ; Configura conversor A/D para portas digitais
      movlw 07h		    ; Habilita 00000111 no registrador work
      movwf CMCON	    ; Desabilita o comparador para uso com entradas digitais
      
      BANKSEL STATUS
      BSF  STATUS,0	    ; Vai pro banco 1
      movlw D'12'	    ; Baud rate 4800 bps
      movwf SPBRG

      ; Configura o TX
      movlw B'00100100'
      movwf TXSTA

      ; Configura o RX
      movlw B'10000000'
      movwf RCSTA
      BSF RCSTA,4	    ; ENABLE USART RECEIVE

      movlw D'20'
      movwf SPBRG
      BCF TRISC,LED	    ; Habilito output pino de LED
      BSF TRISC,RX	    ; Habilita recebimneto de dado, pino de leitura
      CLRF TRISB

      movlw 0xFF	    ; Define o valor 255 no registrador work
      movwf Delay1	    ; Define o delay como 255 ciclos

      banksel TRISB
      CLRF PORTB
      goto REC		    ; Vai para rotina de recebimento REC
      
; Funcao de recebimento
REC:
      BTFSS PIR1,RCIF	    ; Checa se chegou dado do RX
      goto delay_0	    ; Se nao tem dado vai para delay
      goto CH_D		    ; Se chegou dado vai para rotina de tramento

; Funcao de envio
SEND: 
      btfss TXSTA, TRMT	    ; Testa se esta enviando dado
      goto REC		    ; Caso nao, vai para rotina de recebimento 1
      banksel STATUS
      bcf STATUS, 0
      goto REC		    ; Vai para rotina de recebimento 1

; Funcao emissao L
CH_L: 
      movlw 0x4c	    ; Atribui o caracter L ao registrador WREG.
      subwf RCREG	    ; Subtrai o WREG de RCREG.
      btfss STATUS,Z	    ; Aciona o bit Z caso o valor for 0 e liga o LED.
      goto REC		    ; Vai para a proxima funcao caso nao retorne.
      bsf PORTC,LED	    ; Aciona o LED caso o status for vcerdadeiro.
      movlw 0x4c	    ; Move L para WREG
      movwf PORTB	    ; Envia o dado na porta B
      clrf RCIF		    ; Limpa o RX.
      goto delay_0	    ; Aciona o delay de ruido.
      
; Funcao emissao D
CH_D:   
      movlw 0x44	    ; Atribui o caracter D ao registrador WREG.
      subwf RCREG	    ; Subtrai o WREG de RCREG.
      btfss STATUS,Z	    ; Aciona o bit Z caso o valor for 0 e liga o LED.
      goto CH_L		    ; Vai para a funcao RX caso nao retorne.
      bcf PORTC, LED	    ; Aciona o LED caso o status for vcerdadeiro.
      movlw 0x44	    ; Move D para WREG
      movwf PORTB	    ; Envia o dado na porta B
      clrf RCIF		    ; Limpa o RX.
      goto delay_0	    ; Aciona o delay de ruido.

; Funcao delay 1
delay_0:
      DECFSZ Delay1, 1	    ; Decrementa o Delay1 de 1, vai para endloop se Delay1 = 0
      goto delay_0	    ; Vai para delay_1 e inicia decremento do Delay2
      MOVLW 0xFF	    ; Define o valor 255 no registrador work
      MOVWF Delay1	    ; Define o delay como 255 ciclos
      goto CHECK_BTN1	    ; Rotina de testes BTN1

; Funcao delay 2
delay_1:
      DECFSZ Delay1, 1	    ; Decrementa o Delay2 de 1, vai para delay_0 se Delay2 = 0
      goto delay_1	    ; Gera um loop até o Delay2 ser 0
      MOVLW 0xFF	    ; Define o valor 255 no registrador work
      MOVWF Delay1	    ; Define o delay como 255 ciclos
      goto CHECK_BTN2	    ; Rotina de testes BTN2

; Funcao teste de botao LIGAR
CHECK_BTN1:
      btfss PORTA, BTNON    ; Verifica se botao ON foi ativado
      goto delay_1	    ; Caso nao vai para o delay_1
      movlw 0x4c	    ; Move L para WREG
      movwf TXREG	    ; Joga REG para o registrador de envio
      goto SEND		    ; Vai para rotina de envio

; Funcao teste de botao DESLIGAR
CHECK_BTN2:
      btfss PORTA, BTNOFF   ; Verifica se botao OFF foi ativado
      goto REC		    ; Caso nao vai para o rotina de recebimento
      movlw 0x44	    ; Move D para WREG
      movwf TXREG	    ; Joga REG para o registrador de envio
      goto SEND		    ; Vai para rotina de envio

      end
