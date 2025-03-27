  Group Project

  Members: Roles and responsibilities

  Zhenyu Dai:
  
    Explain code for Exercise 3
    
    Demonstrate code for Exercise 3

    Compile code for Exercise 5
    
  Wenxuan Duan:
  
    Explain code for Exercise 4
    
    Demonstrate code for Exercise 4
    
  Jacqueline Ford:
  
    Explain code for Exercise 2
    
    Demonstrate code for Exercise 2
    
  Melvin Lanojan:
  
    Set up GitHub and write down meeting minutes
    
    Explain code for Exercise 1
    
    Demonstrate code for Exercise 1

  Instructions for user:

    To run all exercises, create a new project in STM32CubeIDE.
    Delete the .c files made in the Src folder.
    Copy all the files from the Src folder for each exercise in this repository, and insert it into the Src folder in your project.
    Open the assembly.s file in your project, and run it to start the code, or press debug to see each step of the code.
  
    Exercise 1:
      For a:
        Open the assembly.s file.
        Change the input string in line 9 to whatever you want.
        Set the mode to turn the string into uppercase or lowercase, by changinge line 17 with a 0 to convert to lower, or a 1 to convert to upper.

      For b:
        Open the assembly.s file.
        Change the input string in line 7 to whatever you want. This will be the string which will be tested if it is a palindrome or not.
        All special characters will be ignored, so "RAC$#$CaR" will be read as "RACCaR"
        Step through the code until it finishes. If R0 contains '0', it is not a palindrome, if it contains '1', it is a palindrome.
        
      For c:
        Open the assembly.s file.
        Change the input string in line 7 to whatever you want. This will be the string which will be encoded/decoded.
        Change the number in line 14 to change the value at which it shifts each letter.
        Step through the code until it reaches 'finished'.
        The final encoded/decoded string will be stored in R0. Convert it into ASCII to read the ciphered/deciphered string.
        
    Exercise 2:
      For a:
        Go to 'Exercise 2' folder and use files from 'Exercise2-a'.
        Access the assembly.s file.
        The string of bits in line 25 controls which LEDs will be on at a time, change the values to create your own pattern.
        A '1' in the string means the corresponding LED will be on initally, and a '0' means the corresponding LED will be off initially.
        The code will alternate between the initally lit up LEDs being on and the initally off LEDs being on.

      For b:
        Go to 'Exercise 2' folder and use files from 'Exercise2-b-and-c'.
        Access the assembly.s file.
        The led_state is set in line 13 to have all the LEDs off initally.
        The code will then turn them on one-by-one with each button press.

      For c:
        Go to 'Exercise 2' folder and use files from 'Exercise2-b-and-c'.
        Access the assembly.s file.
        The led_state is set in line 13 to have all the LEDs off initally.
        The code will then turn them on one-by-one with each button press.
        Once all the LEDs are on, each button press will turn them off one-by-one.
        Once all the LEDs are off again, the code will return to its initial function of turning them on one-by-one.

      For d:
        Go to 'Exercise 2' folder and use files from 'Exercise2-d'.
        Access the assembly.s file.
        In line 13 is the ascii_string which will be analyzed by the code.
        Replace the text inside "Hello\0" with anything of your choosing.
        The code will count the number of vowels and store them in a register.
        It will then count the number of consonants and store them in a different register. Special characters are ignored.
        The LEDs will defaultly display the number of vowels in bit representation.
        Once the button is pressed, they will instead display the number of consonants.
        Pressing the button again will return the LEDs to their original state of displaying vowels.
        

    Exercise 3:
      For a:  
        Demonstrates how to receive data via USART1 from the computer's serial port.  
        The microcontroller listens for incoming messages and stores them upon receipt.  
        This sets the foundation for later transmission and forwarding exercises.
      
      For b:  
        Demonstrates how to transmit data from the microcontroller to the computer using USART1.  
        The message is predefined and sent out through the serial port.  
        Useful for testing basic transmission and UART configuration.
      
      For c:  
        Demonstrates how to change the clock speed and configure a different Baud rate.  
        You can observe how varying the system clock affects serial communication.  
        This is helpful for understanding timing sensitivity in UART communication.
      
      For d:  
        Demonstrates message forwarding using USART1.  
        The microcontroller receives a message from the computer via USART1 and immediately transmits it back.  
        This tests both the receive and transmit pathways and verifies correct forwarding logic in a single microcontroller setup.
      
      For e:  
        Demonstrates a port-forwarding process between two microcontrollers.  
        - The first computer sends a message to the first microcontroller via USART1.  
        - The first microcontroller forwards the message using UART4 to the second microcontroller.  
        - The second microcontroller receives the message via UART5.  
        - The message is then transmitted to a second computer via USART1.  
        This exercise combines the techniques from a), b), and d), incorporating multi-port communication and end-to-end message passing.


    Exercise 4:
      For a:
        The program enables Timer2 and continuously reads the counter value to implement hardware-based precise delay.
        After each delay cycle, the LED state is toggled via a bitwise XOR operation, creating a blinking effect.
        This setup utilizes an 8MHz timer frequency, allowing the delay to be accurately controlled down to the microsecond level by setting delay_time.
        
      For b:
        Building upon Timer2 initialization, this program introduces the prescaler (TIM_PSC) to support longer delay durations.
        By adjusting the prescaler value, users can select different time resolutions and ranges (e.g., microseconds, milliseconds, seconds, or even hours).
        Combined with the delay_time variable and accurate counter comparison logic, the LED will blink at specific time intervals, enabling multi-scale hardware delay control.
        Delay Examples
            - For 1 microsecond delay:
              At 8MHz, the counter needs 8 ticks per microsecond.
              Set TIM_PSC = 0 (no prescaling) for maximum resolution.
              Set delay_time = 8 to achieve a precise 1μs delay.
              
            - For 1 second delay:
              The counter must count 8,000,000 ticks.
              Since the prescaler maxes out at 65535, we increase the counter target instead.
              Keep TIM_PSC = 0, and set delay_time = 0x7A1200 (8,000,000) to get 1 second delay.
              
            - For 1 hour delay (3600 seconds):
              Use the prescaler to stretch the timing interval.
              Set TIM_PSC = 3599 (0xE0F in hex), so each tick spans ~450μs.
              Combine it with a suitably large delay_time to achieve hour-level delay.

      For c:
        This program configures the prescaler TIM_PSC to reduce the 8MHz timer frequency, allowing for longer delay cycles.
        Together with TIM_ARR (Auto-Reload Register) and the UIF timeout flag, it enables stable and precise hardware timing control.
        

    Exercise 5:
        This exercise integrates functionalities from other exercises. The computer uses serial communication to send a message to a microcontroller, which checks whether the message is a palindrome; if it is,           it encrypts the message and sends it, otherwise it sends the message directly to a second microcontroller. The second microcontroller decrypts the message and, at 500-millisecond intervals, displays the          occurrence count of each vowel letter via LED lights. This task involves serial communication (between the computer and the microcontroller as well as between microcontrollers), string and memory       
        manipulation, digital I/O, and hardware timers.
      

  Test procedures:

    Exercise 1:
      For a:
        Change the 'input_string' to whatever you want. Have a mix of upper or lower case letters, and special characters.
        Change line 17 to set the code to the conversion mode you want to test.
        With the 'assembly.s file open, press the debug button, which will run the program in debug mode.
        Look for the 'registers' tab, and have 'General Register' open.
        Click on R1 (This is where the string is stored), and copy the hex value address of R1.
        Open the 'memory' tab, press the plus button and insert the address. Close the tab it opens, and then click ASCII to view the string.
        Step through the code.
        When you step through the code and reach the 'conversion_to_upper' or 'conversion_to_lower' function based on your module, look at the monitor, and you will notice that as it cycles through the string past these modules, the string stored in R1 will convert to either upper or lower case.
        When you continue stepping through and reach 'finished_string', the monitor should display a fully converted string.

      For b:
        Change the 'input_string' to whatever you want. Have a mix of upper or lower case letters, and special characters. Set it to a known palindrome to reach 'is_palindrome' in the code
        With the 'assembly.s file open, press the debug button, which will run the program in debug mode.
        Look for the 'registers' tab, and have 'General Register' open.
        Step through the code.
        When you continue stepping through and reach 'finished_string', look at the value stored in r0, it should show a value of 0 if the input string doesn't classify as a palindrome, and a value of 1 if it does.
        
      
      For c:

    Exercise 2:
      For a:
        Change the 0s and 1s after '0b' in line 25 (LDR R4, =0b00010001) to a desired pattern. These 8 numbers each correspond to an individual LED on the discovery board. Placing a 0 in the string means that LED will initially be off, and placing a 1 means that the LED will initially be on. The LEDs will then alternate between being on and being off continuously.
        Comment out line 35 to leave the LEDs in their initial state to check if it is as expected.
        Change the delay size in line 42 to a larger number to see the LEDs alternate slower for a better look at the transition.

      For b:
        Comment out lines 51 and 52 to prevent the LEDs from turning off on button press once they are all turned on.
        Change the value of the bit string in line 13 to test whether the LED display is working properly. They will be initially set to whatever pattern you input after 0b, where 1 will make the LED on and 0 will make the LED off.
        Replace the button_down function with this code, which will just turn on and off 1 LED, to test whether the button is working and being read properly:
        button_down:
          LDR R0, =GPIOE
          LDR R1, [R0, #ODR]
          EOR R1, R1, #0x0100   @ Toggle PE8 (bit 8)
          STR R1, [R0, #ODR]
          BL delay_function
          B idle_on

        Change the value of #1 in line 54 to change the next led that will turn on with button press. (Eg. if you change it to #2, every second LED will turn on with button press.) This will also allow you to check that the LEDs do not start turning off unless they are all on)

        For c:
          Use testing procedures listed above for part b.

          Change the value of the bit string in line 13 to test whether the LED display is working properly. Change all of the 0s after '0b' to 1s to test if there is an issue with the way the LEDs turn off.
          Change the value of #1 in line 54 to change the next led that will turn on with button press. (Eg. if you change it to #2, every second LED will turn on with button press.) This will also allow you to check that the LEDs do not start turning off unless they are all on)
          Change the value of #1 in line 73 to change how many leds will turn off with button press. (Eg. if you change it to #2, LEDs will turn off in pairs on button press.) This will allow you to check if they are turning off correctly.

        For d:
        Change the string "Hello\0" in line 13 to whatever string you want to be analyzed. For testing it is easier to use a small amount of characters so that you know the bit value of the number of vowels and consonants.
        To test whether the LEDs are correctly displaying the vowel and consonant registers, change the values loaded into R4 and R5 in the main function from 0, then jump directly to display_result. They LEDs should defaulty display whatever is loaded into R4, then change to the number loaded into R5 on button press. Example:
          MOV R4, #10 @ Loads a value of 10 into the vowel count
          MOV R5, #16 @ Loads a value of 16 into the consonant count
          BL display_result
        This will allow you to see if there is an issue with the counting logic.
          

          

    Exercise 3:
      For a:
        Run the code on the STM32 board: Build and flash the project using STM32CubeIDE or your chosen tool.
        Open the serial terminal on your computer: Select the correct COM port and set the baud rate (e.g., 115200, 8N1).
        Press the blue user button on the board: Each press triggers the program to send a predefined string over USART.
        Check the serial monitor for output: You should see the string followed by a terminating character appear.
        Hold the button to see repeated messages: While holding, the message is sent repeatedly with a delay between prints.
  
      For b:
        Run the code on the STM32 board: The program sends a predefined message via USART1.
        Open the serial monitor on your computer: You should see the transmitted string appear on the screen.
  
      For d:
        Run the code on a single STM32 board: This project receives data from one USART and forwards it to another.
        Open the serial monitor on your computer: Type a message into the input terminal connected to USART1.
        Observe forwarded output on a second serial port: The message is transmitted via a different UART.
        This test shows real-time data routing: Demonstrates the microcontroller acting as a basic serial bridge.
  
      For c:
        Run the code in debug mode: Load the program and start debugging in STM32CubeIDE.
        Open a serial monitor at 57600 baud: Set correct COM port, 57600 baud rate, 8N1 format, no flow control.
        Type any text into the serial monitor: The input will be received by the microcontroller.
        Pause the code execution: Use the IDE's suspend/pause button during debugging.
        Check register R6 in the debugger: It should contain the data you typed from the serial terminal.
  
      For e:
         Use two STM32 boards and two computers: Each board connects to a different computer via USB.
         Run the transmission project on Board 1: Connect Board 1 to PC1 and open its serial terminal.
         Run the receiving project on Board 2: Connect Board 2 to PC2 and open its serial terminal.
         Connect the boards: GND ↔ GND, PX10 (TX) ↔ PD2 (RX): Ensure correct UART wiring between the two boards.
         Type a sentence on PC1 and press send: The message should appear on PC2’s terminal window.
         Use the memory browser to check R1 on both boards: On Board 1 it should show the encrypted message, and on Board 2, the decrypted one.
         This demo tests full communication and cipher logic: It integrates UART, USART, encryption, decryption, and forwarding.

    Exercise 4:
      For a:
        The program uses Timer2 for precise delay and controls the LED blinking via hardware_delay.
        Locate the delay_time variable in the .data section.
        Its default value is 0x08, meaning 1 microsecond delay (8MHz timer → 125ns per tick, so 8 ticks ≈ 1μs).
        Since 1μs delay is too short to observe visually, you can extend the delay by changing the value on line 12 to something higher.
        Alternatively, use an oscilloscope to detect the waveform and calculate timing based on pulse intervals.
        Click the Debug button to enter debug mode and step through the program.
        Inside main, peripherals are initialized, Timer2 is enabled, and the code enters an infinite loop.
        Open the Registers panel, locate Timer2, and monitor CNT (counter) and CR1 (control register).
        Check if CNT is incrementing and resetting — this indicates the timer is running correctly.
        Also view the GPIOE output state.
        Each time led_toggle runs, bits 8–15 of the ODR register are XORed with 0x55, toggling the LEDs.
        Watch changes in the registers or directly in GPIOE->ODR.

      For b:
        Check the delay_time variable in the .data section.
        Default is 0x08, which results in 1μs delay under 8MHz with no prescaler.
        To change the delay, modify the counter value on line 12 and the prescaler value on line 45.
        Use the equation: counter value / delay time = counter frequency / prescaler value
        The counter frequency is 8MHz. Plug in your desired delay to calculate suitable counter value and prescaler value.
        Important: Subtract 1 from the prescaler value to get the actual TIM_PSC register value, since it starts from 0.
        To test longer delays, uncomment or replace line 20 with 0x7A1200 (8,000,000 ticks = 1 second).
        This program supports three timing configurations via TIM_PSC and delay_time: 
        Microsecond-level: PSC = 0, delay_time = 8
        Second-level: PSC = 0, delay_time = 8000000 
        Hour-level: PSC = 3599 (0xE0F), with a large delay_time
        Run the debugger. Once initialized in main, the program enters Led_loop, toggles the LED, and waits via hardware_delay.
        Observe delay behavior:
        Open Registers to monitor TIM_CNT, ensuring it counts from 0 to your defined delay_time.
        Inside hardware_delay, the counter increments until CNT >= delay_time, then resets.
        At delay_time = 8000000, the LED blinks once per second; at delay_time = 28800000, once per hour.

      For c:
        This task demonstrates longer, more stable delays by reducing the timer frequency using TIM_PSC.
        Find delay_time in the .data section.
        Initial value is 0x08, which sets the auto-reload target (TIM_ARR).
        Modify this value — e.g., try 0x50 or 0x100 — to compare delay durations.
        The program sets TIM_PSC = 0x63 (99 decimal), reducing the 8MHz frequency to 80kHz.
        This means even small ARR values yield noticeable delays (e.g., ARR = 8 gives ~0.1ms).
        After setup, it calls trigger_prescaler to apply the prescaler change properly.
        Click Debug, step into the program. After initialization, it enters Led_loop, toggling the LED and invoking hardware_delay.
        Monitor Timer Behavior:
        hardware_delay writes delay_time into TIM_ARR (Auto-Reload).
        Then it loops at wait_for_timeout, checking TIM_SR for the UIF flag (Update Interrupt Flag).
        Once the flag is set, the program clears it and continues looping.
        Observe LED behavior via GPIOE->ODR.
        If you're using real hardware, you should see the LED blink at intervals determined by the prescaler and delay_time.
        If using a simulator, watch the Registers or Watches panel for ODR and timer-related changes.
              
    Exercise 5:
    For code that is used from previous parts, test them as individual files using the methods listed above.
