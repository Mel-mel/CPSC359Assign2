.globl      initializeUART

initializeUART:

    //Enable mini-UART. If bit0 is set then its enabled, if not then its disabled.
    ldr    r0, =UART_AUX_EN
    
    //Set bit0. Enable mini-UART
    ldr    r1, [r0]
    orr    r1, #1
    str    r1, [r0]
    
    //Enable interrupts.(should make some of these labels into a function or something...)
    ldr    r0, =UART_AUX_MU_IER
    
    ldr    r1, [r0]
    bic    r1, #0b11    //Clears the entire register
    str    r1, [r0]
    
    //Disabling receiving/transmiting register (aka control register)
    ldr    r0, =UART_AUX_MU_CNTL_REG
    
    ldr    r1, [r0]
    bic    r1, #0b11
    str    r1, [r0]
    
    //Setting symbol width
    ldr    r0, =UART_AUX_MU_LCR_REG
    
    ldr    r1, [r0]
    orr    r1, #0b1      //Setting to 1 will set it to 8 bit mode
    str    r1, [r0]

    //Setting the RTS line to high
    ldr    r0, =UART_AUX_MU_MCR_REG
    
    ldr    r1, [r0]
    bic    r1, #0b10    //Clearing RTS line to set to high
    str    r1, [r0]
    
    //Clearing the input and output lines
    ldr    r0, =UART_AUX_MU_IIR_REG
    
    ldr    r1, [r0]
    orr    r1, #0x000000C6
    str    r1, [r0]
    
    //Setting baud rate
    ldr    r0, =UART_AUX_MU_BAUD_REG
    
    ldr    r1, =270
    str    r1, [r0]
    
    //STEP 8: Setting the GPIO lines 14 and 15
    ldr    r0, =Function_register_1
    
    ldr    r0, =0x20200020
    ldr    r1, [r0]
    mov    r2, #0b111111
    lsl    r2, #12
    bic    r1, r2
    str    r1, [r0]
    //at this point line 14 & 15 are cleared
    
    ldr     r0, =0x20200020
    ldr     r1, [r0]
    mov     r2, #0b010010
    lsl     r2, #12
    orr     r1, r2
    str     r1, [r0]
    //at this point bit 14 & 15 have been set
    
    //STEP 9: Disable pull up/down for GPIO lines 14 and 15
    
    ldr    r0, =GPPUD
    ldr    r1, [r0]
    bic    r1, #0b11    //This is the PUD bit


    mov r2,#150
    mov r3, #0
loop: 
    cmp r2, r3
    bne cont1
    add r3, r3, #1
    b   loop

cont1:
    ldr    r0, =GPPUDClk0
    
    ldr    r1, [r0]
    mov    r2, #0b010010
    lsl    r2, #12
    orr    r1, r2
    str    r1, [r0]
    //at this point CLOCK lines 14 and 15 have been asserted
    
    mov r2,#150
    mov r3, #0
loop2: 
    cmp r2, r3
    bne cont2
    add r3, r3, #1
    b   loop2
  
cont2:
    ldr    r0, =GPPUDClk1
    
    ldr    r1, [r0]
    mov    r2, #0b0111111
    lsl    r2, #12
    bic    r1, r2
    str    r1, [r0]
    
    //STEP 10 - Enable receiving/transmitting
    ldr    r0, =UART_AUX_MU_CNTL_REG
    
    ldr    r1, [r0]
    mov    r2, #0b11
    orr    r1, r2
    str    r1, [r0]
    
    bx	   lr        //Branches back to the main.s


.section .data

//Defining constants 
.EQU    UART_AUX_EN, 0x20215004            //UART auxilary enable register
.EQU    UART_AUX_MU_IER, 0x20215044        //UART interrupt enable register
.EQU    UART_AUX_MU_CNTL_REG, 0x20215060   //UART auxilary control register
.EQU    UART_AUX_MU_LCR_REG, 0x2021504c    //UART line control register
.EQU    UART_AUX_MU_MCR_REG, 0x20215050    //UART modulation control register
.EQU    UART_AUX_MU_IIR_REG, 0x20215048    //UART interrupt status register
.EQU    UART_AUX_MU_BAUD_REG, 0x20215068   //UART baud register

.EQU    Function_register_1, 0x20200004    //Function select 1
.EQU    GPPUD, 0X20200094                  //GPPUD register (pull up/down)
.EQU    GPPUDClk0, 0x20200098              //GPPUD clock register 0
.EQU    GPPUDClk1, 0x2020009c              //GPPUD clock register 1

