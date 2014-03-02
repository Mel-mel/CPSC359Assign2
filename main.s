//Somehow need to copy contents of r0 into another register.
//Then apply this register into getCharLoop line 65

.section .init
.globl starting

starting:
    b go
    .section .text
    
go:
    mov sp, #0x8000
    bl EnableJTAG

    bl	initializeUART
    
    mov r0, #0x41    // ASCII char A
    
loopChar:
    bl putChar

    add r0, #1   
    cmp r0, #0x5A
    ble loopChar
    
haltLoop$:
    b haltLoop$
   
//****************************************************** 
putChar:
	//push {lr}
    ldr r2, =UART_AUX_MU_LSR_REG

inLoop:
    //Need to wait until bit 5 is set
    ldr r1, [r2]
    tst r1, #0x20 						//Testing bit 5
    beq inLoop

    //Write the character to the IO register
    ldr r2, =UART_AUX_MU_IO_REG
    str r0, [r2]
 
    b getChar

    mov pc, lr
    //pop {lr}
    //bx lr

//******************************************************

getChar:
    //push {lr}
    ldr r2, =UART_AUX_MU_LSR_REG
    
getCharLoop:
    //wait until data is ready (LSR bit 0 is set) 
    //ldr r3, [r2]
    mov r3, r0
    tst r3, #0b1 						//We have to test bit 0
    beq getCharLoop
       
    //write character to IO register
    ldr r2, =UART_AUX_MU_IO_REG
    ldr r0, [r2]					//??????????*************
    
    mov pc, lr
    //pop {lr}
    //bx lr

//******************************************************

.section .data
.EQU UART_AUX_MU_LSR_REG, 0x20215054 	//Line status register
.EQU UART_AUX_MU_IO_REG, 0x20215040 	//IO register


