################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (12.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/assembly.s \
../Src/cipher.s \
../Src/definitions.s \
../Src/initialise.s \
../Src/lower_conversion.s 

OBJS += \
./Src/assembly.o \
./Src/cipher.o \
./Src/definitions.o \
./Src/initialise.o \
./Src/lower_conversion.o 

S_DEPS += \
./Src/assembly.d \
./Src/cipher.d \
./Src/definitions.d \
./Src/initialise.d \
./Src/lower_conversion.d 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s Src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -DDEBUG -c -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Src

clean-Src:
	-$(RM) ./Src/assembly.d ./Src/assembly.o ./Src/cipher.d ./Src/cipher.o ./Src/definitions.d ./Src/definitions.o ./Src/initialise.d ./Src/initialise.o ./Src/lower_conversion.d ./Src/lower_conversion.o

.PHONY: clean-Src

