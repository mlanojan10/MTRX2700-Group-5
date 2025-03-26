  Group Project

  Members: Roles and responsibilities

  Zhenyu Dai:
  
    Explain code for Exercise 3
    
    Demonstrate code for Exercise 3
    
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
        The final encoded/decoded string will be stored in R0. Convert it into ASCII to read the string.
        
    Exercise 2:
      For a:
        Go to 'Exercise 2' folder and use files from 'Exercise2-a'.
        Access the assembly.s file.
        The string of bits in line 24 controls which LEDs will be on at a time, change the values to create your own pattern.
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
        Go to 'Exercise 2' folder and use files from 'Exercise2d'.
        Access the assembly.s file.
        In line 13 is the ascii_string which will be analyzed by the code.
        Replace the text inside "Hello\0" with anything of your choosing.
        The code will count the number of vowels and store them in a register.
        It will then count the number of consonants and store them in a different register. Special characters are ignored.
        The LEDs will defaultly display the number of vowels in bit representation.
        Once the button is pressed, they will instead display the number of consonants.
        Pressing the button again will return it to its original state.
        

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

    Exercise 5:
      

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
        
      
      For c:

    Exercise 2:

    Exercise 3:

    Exercise 4:

    Exercise 5:
