.syntax unified
.thumb

#include "initialises_c.s"

.global main

.data
.align

delay_time:
    .word 0x08                     @ Delay time in ticks (8 ticks = 1us if 8MHz and PSC=99)
                                   @ Timer frequency = 8MHz / (PSC + 1) = 80kHz → 1 tick = 12.5μs
                                   @ So 8 × 12.5μs = 100μs delay

.text

@ ------------------------------------------------------------------
@ Main function: configures peripherals and enters LED toggle loop
@ ------------------------------------------------------------------
main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    @ Enable TIM2 (start counting)
    LDR R0, =TIM2
    MOV R1, #0x01                  @ Set CEN (counter enable) bit
    STR R1, [R0, TIM_CR1]

    @ Configure Prescaler = 99 → actual division = 100
    LDR R0, =TIM2
    MOV R1, #0x63                  @ 0x63 = 99 decimal
    STR R1, [R0, TIM_PSC]          @ Set prescaler register

    BL trigger_prescaler           @ Force prescaler to take effect immediately

@ ------------------------------------------------------------------
@ Infinite loop: toggle LED with delay
@ ------------------------------------------------------------------
Led_loop:
    BL led_toggle
    BL hardware_delay              @ Wait using hardware timer
    B Led_loop

@ ------------------------------------------------------------------
@ Toggles upper half of GPIOE (e.g., PE8–PE15)
@ ------------------------------------------------------------------
led_toggle:
    LDR R0, =GPIOE
    LDR R1, [R0, #ODR + 1]         @ Read high byte of output data register (ODR)
    EOR R1, R1, #0x55              @ XOR with 0x55 (toggle bits)
    STR R1, [R0, #ODR + 1]         @ Write back updated value
    BX LR

@ ------------------------------------------------------------------
@ Implements hardware delay using TIM2 ARR and UIF flag
@ ------------------------------------------------------------------
hardware_delay:
    LDR R0, =TIM2                  @ Load TIM2 base address
    LDR R2, =delay_time
    LDR R1, [R2]                   @ Load delay count (in ticks) from memory

    STR R1, [R0, TIM_ARR]          @ Set Auto-Reload Register (ARR)
    MOV R2, #0x01
    STR R2, [R0, TIM_CR1]          @ Re-enable timer (CEN = 1)

    MOV R2, #0x81                  @ ARPE = 1 (Auto-reload preload), CEN = 1
    STR R2, [R0, TIM_CR1]

wait_for_timeout:
    LDR R2, [R0, TIM_SR]           @ Read TIM2 status register
    ANDS R2, R2, #0x01             @ Check UIF (Update Interrupt Flag)
    BEQ wait_for_timeout           @ Wait until UIF is set (timeout)

    MOV R2, #0x00
    STR R2, [R0, TIM_SR]           @ Clear UIF flag

    BX LR

