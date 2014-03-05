//Richard Huynh			UCID: 10099642
//Melissa Ta			UCID: 10110850
//Yin-Li (Emily) Chow	        UCID: 10103742
.globl initializeUART

initializeUART:
//Step 1. Enable mini UART
    ldr r0, =UART_AUX_EN 		//Getting address of UART_AUX_EN
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    orr r1, #0b1 			//Setting bit 0 to enable mini UART
    str r1, [r0] 			//Store r1 at address of r0
    
//Step 2. Disable interrupts
    ldr r0, =UART_AUX_MU_IER 		//Getting address of UART_AUX_MU_IER
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    bic r1, #0xFFFFFFFF 		//Clears the entire register
    str r1, [r0] 			//Store r1 at address of r0
    
//Step 3. Disabling receiving/transmiting register
    ldr r0, =UART_AUX_MU_CNTL_REG 	//Getting address of UART_AUX_MU_CNTL_REG
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    bic r1, #0b11 			//Clearing bits 0 and 1 for transmitter/reciever
    str r1, [r0] 			//Store r1 at address of r0
    
//Step 4. Setting symbol width (# of bits)
    ldr r0, =UART_AUX_MU_LCR_REG 	//Getting address of UART_AUX_MU_LCR_REG
    ldr r1, [r0] 			//Loading value at address of r0 and put into r1
    orr r1, #0b11 			//Setting but 0 to 1 to enable 8 bit mode
    str r1, [r0] 			//Store r1 at address of r0

//Step 5. Setting the RTS line to high
    ldr r0, =UART_AUX_MU_MCR_REG 	//Getting address of UART_AUX_MU_MCR_REG
    ldr r1, [r0]	 		//Loading value at address r0 and put into r1
    bic r1, #0b10 			//Clearing RTS line at bit 1 to set to high
    str r1, [r0] 			//Store r1 at address of r0
    
//Step 6. Clearing the input and output buffers
    ldr r0, =UART_AUX_MU_IIR_REG 	//Getting address of UART_AUX_MU_IIR_REG
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    orr r1, #0x000000C6 		//Enable FIFO then clearing bits 1 and 2 by setting them to 1
    str r1, [r0] 			//Store r1 at address of r0
    
//Step 7. Setting baud rate
    ldr r0, =UART_AUX_MU_BAUD_REG 	//Getting address of UART_AUX_MU_BAUD_REG
	ldr r1, [r0]                    //Loading value at address r0 and put into r1
	ldr r2, =baudRate               //Getting address of baudRate
	ldr r3, [r2]                    //Loading value at address r2 and put into r3
	orr r1, r2                      //Setting baud rate to 270
    str r1, [r0] 			//Store r2 at address of r0

//STEP 8: Setting the GPIO lines 14 and 15
    //Clearing bits 14 and 15
    ldr r0, =Function_register_1 	//Loading address of Function_register_1 into r0
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    mov r2, #0b111111 			//Moving bit mask 111111 into r2
    lsl r2, #12 			//Logically shifting left 12 times
    bic r1, r2 				//Clearing r1 with r2 (bit mask)
    str r1, [r0] 			//Store r1 into address of r0

    //Setting bits 14 and 15
    ldr r0, =Function_register_1
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    mov r2, #0b10010 			//Moving bit mask 010010 into r2
    lsl r2, #12 			//Logically shifting left 12 times
    orr r1, r2 				//Setting bits 14 and 15 using r2 (bit mask)
    str r1, [r0] 			//Store r1 into address of r0
 
//STEP 9: Disable pull up/down for GPIO lines 14 and 15
    ldr r0, =GPPUD 			//Getting address of GPPUD
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    bic r1, #0b11 			//Clearing bit 0 and 1 with bit mask of 11 (Turining off clock signal)
    mov r2, #150 			//Moving 150 into r2
    mov r3, #0 				//Moving 0 into r3

loop:
    cmp r2, r3 				//Compare r2 and r3
    beq cont1 				//Branch out if r2 and r3 equal 150
    add r3, r3, #1 			//Incrementing r3 by 1
    b loop 				//Branch back to loop

cont1:
    ldr r0, =GPPUDClk0 			//Getting address of GPPUDClk0
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    mov r2, #0b111111 			//Moving bit mask 010010 into r2
    lsl r2, #12 			//Logically shifting left 12 times
    orr r1, r2 				//Setting clock line bits 14 and 15 (Bits have been asserted)
    str r1, [r0] 			//Store r1 into address of r0
    mov r2,#150 			//Moving 150 into r2
    mov r3, #0 				//Moving 0 into r3

loop2:
    cmp r2, r3 				//Comparing r2 and r3
    beq cont2 				//Branch out if r2 and r3 equal 150
    add r3, r3, #1 			//Incrementing r3 by 1
    b loop2 				//Branch back to loop2
  
cont2:
    ldr r0, =GPPUDClk0 			//Getting address of GPPUDClk0
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    mov r2, #0b111111	 		//Moving bit mask 111111 into r2
    lsl r2, #12 			//Logically shifting left 12 times
    bic r1, r2 				//Clearing clock line bits 14 and 15
    str r1, [r0] 			//Store r1 into adddress of r0

//STEP 10 - Enable receiving/transmitting
    ldr r0, =UART_AUX_MU_CNTL_REG 	//Getting address of UART_AUX_MU_CNTL_REG
    ldr r1, [r0] 			//Loading value at address r0 and put into r1
    mov r2, #0b11 			//Moving bit mask 11 into r2
    orr r1, r2 				//Setting reciever and transmitter enable bits at bit 0 and 1
	str r1, [r0] 			//Store r1 into address of r0
    bx	lr 				//Branches back to the main.s


.section .data

//Defining constants
.EQU UART_AUX_EN, 0x20215004 		//UART auxilary enable register
.EQU UART_AUX_MU_IER, 0x20215044        //UART interrupt enable register
.EQU UART_AUX_MU_CNTL_REG, 0x20215060 	//UART auxilary control register
.EQU UART_AUX_MU_LCR_REG, 0x2021504c 	//UART line control register
.EQU UART_AUX_MU_MCR_REG, 0x20215050 	//UART modulation control register
.EQU UART_AUX_MU_IIR_REG, 0x20215048 	//UART interrupt status register
.EQU UART_AUX_MU_BAUD_REG, 0x20215068 	//UART baud register

.EQU Function_register_1, 0x20200004 	//Function select 1
.EQU GPPUD, 0X20200094 			//GPPUD register (pull up/down)
.EQU GPPUDClk0, 0x20200098 		//GPPUD clock register 0
.EQU GPPUDClk1, 0x2020009c 		//GPPUD clock register 1
.EQU baudRate, 0x10E			//Baud rate is 270
