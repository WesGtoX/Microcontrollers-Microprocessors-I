/*
 * Programa de transmissão em C
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

// Declaração de funções

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
    
    //Habilitar modo assíncrono
    SYNC = 0;
    SPEN = 1;
    
    //configura os pinos
    TRISC6 = 1;
    TRISC7 = 1;
    TXEN = 1;
}

// função write port
void UART_Write(uint8_t dado){
    while(!TRMT){
        TXREG = dado;
    }
}

// Rotina principal
void main(void){
    
    UART_TX_Init();
    UART_Write(0x41); // letra A maíuscula
    
    //
    while(1){
        // podemos colocar outras coisas
        
    }
    return;
}

