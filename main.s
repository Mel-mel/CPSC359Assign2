.section .init
.globl starting

starting:
    b go
    .section .text
    
go:
    mov sp, #0x8000
    bl EnableJTAG

    bl	initializeUART
    
    mov r0, #0x41
    
loopChar:
    bl putChar

    add r0, r0, #0x1   
    cmp r0, #0x5A
    blt loopChar
    
haltLoop$:
    b haltLoop$
   
//****************************************************** 
putChar:
    ldr r3, =UART_AUX_MU_IO_REG

inLoop:
    //Need to wait until bit 5 can accept at least one byte
    ldr r1, [r3]
    tst r1, #0x20 						//Testing bit 5
    beq inLoop

    //Write the character to the IO register
    ldr r2, =UART_AUX_MU_IO_REG
    //ldr r3, 0x41						// write current ASCII
    str r3, [r2]
 
    mov pc, lr

//******************************************************

getChar:
    ldr r0, =UART_AUX_MU_LSR_REG
    
getCharLoop:
    ldr r1, [r2]
    tst r1, #0x1 						//We have to test bit 0
    beq getCharLoop
    
    ldr r2, =UART_AUX_MU_IO_REG
    ldr r0, [r2]
    
    mov pc, lr

//******************************************************

.section .data
.EQU UART_AUX_MU_LSR_REG, 0x20215054 	//Line status register
.EQU UART_AUX_MU_IO_REG, 0x20215040 	//IO register

