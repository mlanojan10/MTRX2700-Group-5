.syntax unified
.thumb

#include "initialise.s"

.global main

.data
.align

@ Define delay time (in ticks)
delay_time:
    .word 0x08                  @ 8 ticks = 1 microsecond (when tick = 0.125us with 8MHz clock)

.text

@ ------------------------------------------------------------------
@ Entry point: initializes peripherals and enters infinite delay loop
@ ------------------------------------------------------------------
main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    @ Start the counter running
    LDR R0, =TIM2              @ Load TIM2 base address
    MOV R1, #0b1               @ Set CEN = 1 (enable counter)
    STR R1, [R0, TIM_CR1]      @ Write to control register

@ ------------------------------------------------------------------
@ Infinite loop with delay
@ ------------------------------------------------------------------
Delay_loop:
    BL hardware_delay          @ Call delay function
    B Delay_loop               @ Loop forever

@ ------------------------------------------------------------------
@ Delay function using TIM2 counter polling
@ ------------------------------------------------------------------
hardware_delay:
    LDR R0, =TIM2              @ Load base address of TIM2
    MOV R2, #0
