/*
 * File:   pic_lcd.c
 * Author:
 *      Quemuel Alves Nassor - 828461
 *      Wesley de Oliveira Mendes - 828507
 *
 * Created on 10 de Dezembro de 2020, 10:06
 */

#include <xc.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pic18f4550.h>

//#fuses HSPLL,NOWDT,NOPROTECT,NOLVP,NODEBUG,USBDIV,PLL5,CPUDIV1,VREGEN

//#fuses xt, nowdt, noprotect, put, brownout 
//#use delay(clock = 4000000);
#define _XTAL_FREQ 4000000
#define Baud 9600

#define RS  PIN_E0
#define EN  PIN_E1

void Inicializa(void);

void Lcd_Inst(char dado);

void Lcd_Dado(char dado);

void Mensagem(void);

void main(void) {
    Inicializa();
    Mensagem();
    while (true);
}

void Inicializa(void) {
    Setup_ADC(ADC_OFF);
    Set_Timer0(0);
    Setup_Timer_0(RTCC_INTERNAL | RTCC_DIV_256);
    Setup_Timer_0(0 | 3);
    __enable_interrupt(TMR0IE);
    __enable_interrupt(GLOBAL);
    Lcd_Inst(0x38);
    __delay_ms(2);
    Lcd_Inst(0x38);
    Lcd_Inst(0x0C);
    Lcd_Inst(0x06);
    Lcd_Inst(0x01);
    __delay_ms(1);
}

//#int_timer0
void isr_timer0(void) {
    Lcd_Inst(0x1C);
}

void Mensagem(void) {
    Lcd_Inst(0x92);
    printf(Lcd_Dado, "ENGENHARIA DE COMPUTACAO");
    Lcd_Inst(0xCF);
    printf(Lcd_Dado, "Microcontroladores e Microprocessadores I");
}

void Lcd_Inst(char dado) {
    __disable_interrupt(GLOBAL);
    __output_low(RS);
    __output_d(dado);
    __delay_cycles(2);
    __output_high(EN);
    __delay_ms(1);
    __output_low(EN);
    __enable_interrupt(TMR0IE);
}

void Lcd_Dado(char dado) {
    __disable_interrupt(GLOBAL);
    __output_high(RS);
    __output_d(dado);
    __delay_cycles(2);
    __output_high(EN);
    __delay_ms(1);
    __output_low(EN);
    __enable_interrupt(GLOBAL);
}
