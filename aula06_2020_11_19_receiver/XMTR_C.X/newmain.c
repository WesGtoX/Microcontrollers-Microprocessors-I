/*
 * Programa de transmiss�o em C
 * USART do PIC18F4550
 * 
 * Author: Wesley de Oliveira Mendes - 828507
 */

#include <xc.h>
#include <stdint.h>
// #include "config.h"
// #include <p18f4550.h>

#define _XTAL_FREQ 4000000
#define Baud 9600

// Declara��o de fun��es

// ---UART_TX_Init
void UART_TX_Init(void){
    uint16_t x;
    if(x > 255){
        x = (_XTAL_FREQ - Baud*16)/(Baud*16);
        BRGH = 1;
    }
    
    if(x <= 255){
        SPBRG = x;
    }
    
    //Habilitar modo ass�ncrono
    SYNC = 0;
    SPEN = 1;
    
    //configura os pinos
    TRISC6 = 1;
    TRISC7 = 1;
    TXEN = 1;
}

// fun��o write port
void UART_Write(uint8_t dado){
    while(!TRMT){
        TXREG = dado;
    }
}

// Rotina principal
void main(void){
    
    UART_TX_Init();
    UART_Write(0x41); // letra A ma�uscula
    
    //
    while(1){
        // podemos colocar outras coisas
        
    }
    return;
}

