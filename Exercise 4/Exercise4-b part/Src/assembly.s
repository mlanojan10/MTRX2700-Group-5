.syntax unified
.thumb

#include "initialise.s"

.global main

.data
.align

@ Delay time in timer ticks
delay_time:
    .word 0x08                  @ 8 ticks = 1 microsecond (when tick = 0.125us)

    @ For reference (not active, commented out):
    @ .word 0x7A1200            @ 8,000,000 ticks = 1 second (if prescaler = 0)

.text

@ ------------------------------------------------------------------
@ Entry point
@ ------------------------------------------------------------------
main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    @ Enable TIM2 (start counting)
    LDR R0, =TIM2
    MOV R1, #0b1                @ Set CEN = 1 (enable counter)
    STR R1, [R0, TIM_CR1]

    @ --------------------------------------------------------------
    @ DEMO: Configure Prescaler for different delays
    @ --------------------------------------------------------------
    @ Formula: tick_time = (PSC + 1) / Timer_Clock
    @ Tick period for 8MHz timer with PSC = 99 → tick = 12.5us
    @ → 8 ticks = 100us delay

    @ 0.1 ms delay demo:
    @    PSC = 99 → 0x63
    LDR R0, =TIM2
    MOV R1, #0x63               @ Set Prescaler = 99 → tick = 12.5us
    STR R1, [R0, TIM_PSC]

    @ Notes for other delays (not used directly here):
    @ 1 us delay:     PSC = 0, counter value = 8
    @ 1 sec delay:    PSC = 0, counter value = 8,000,000
    @ 1 hour delay:   PSC = 3599 (0xE0F), counter value = 8,000,000

    BL trigger_prescaler        @ Force prescaler update immediately

@ ------------------------------------------------------------------
@ Main LED toggle loop
@ ------------------------------------------------------------------
Led_loop:
    BL led_toggle
    BL hardware_delay
    B Led_loop

@ ------------------------------------------------------------------
@ Toggle GPIOE[15:8] (assumes LEDs are connected there)
@ ------------------------------------------------------------------
led_toggle:
    LDR R0, =GPIOE
    LDR R1, [R0, #ODR + 1]
    EOR R1, R1, #0x55
    STR R1, [R0, #ODR + 1]
    BX LR

@ ------------------------------------------------------------------
@ Delay function using TIM2 counter polling
@ ------------------------------------------------------------------
hardware_delay:
    LDR R0, =TIM2               @ Load TIM2 base
    MOV R2, #0
    STR R2, [R0, TIM_CNT]       @ Reset counter

    LDR R1, =delay_time
    LDR R1, [R1]                @ R1 = target delay count

delay_loop:
    LDR R3, [R0, TIM_CNT]       @ Load current count
    CMP R3, R1                  @ Compare with delay_time
    BCC delay_loop              @ Wait until CNT >= delay_time
    BX LR

