################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../part3.cu 

OBJS += \
./part3.o 

CU_DEPS += \
./part3.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/home/fsy/cuda/bin/nvcc -G -g -O0 -gencode arch=compute_61,code=sm_61 -m64 -odir "." -M -o "$(@:%.o=%.d)" "$<"
	/home/fsy/cuda/bin/nvcc -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61 -m64  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


