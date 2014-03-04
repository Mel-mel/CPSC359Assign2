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
    ldr r0, =buff
	mov	r1,	#256
	bl readLineUART
	
	mov	r1,	r0
	
	mov	r0,	#0xA
	bl putChar
	
	ldr r0, =buff
	bl writeStringUART
	mov r0, #0xA
	bl putChar

//starting random stuff here	
	ldr r0, =buff
	ldr r2, [r0]
	mov r3, #0x00000000
	and r2, r3
	strb r2, [r0]
	
	
/*	
	mov r0, #0
	ldr r1, =buff
	strb r0, [r1]
*/
	//b clearBuffer

	b go

	//we want to pop r4 and store into r0
	//call putChar (should technically print that letter)
	//Loop this bro. DO IT OVAR AND OVAR AND OVAR.
	//We done bro. (NOW CHECK FOR 'ECHO + ""' and "LED on/off")
	//oh, and make sure to put/print error messages should
	//something other than those two ^ be set as input.

haltLoop$:
    b haltLoop$                 // end program
   
//******************************************************
//This is basically for printing the characters
/* Put a character in the UART transmitter FIFO
*
r0 - char to write(only lower byte used)
* Returns:
*
r0 - character written
*/
putChar:
	ldr r2, =UART_AUX_MU_LSR_REG // line status register
putWaitLoop$:
	ldr r1, [r2]
	tst r1, #0x20 // test bit 5
	beq putWaitLoop$
// wait until LSR bit 5 (transmitter empty) is set
// i.e., wait until line can accept at least one byte
	ldr r2, =UART_AUX_MU_IO_REG // IO register
	str r0, [r2]

// write character to the IO register
	mov pc, lr


//******************************************************

getChar:
	ldr r2, =UART_AUX_MU_LSR_REG // line status reg
getWaitLoop$:
	ldr r1, [r2]
	tst r1, #0x1 // test bit 0
	beq getWaitLoop$
// wait until data is ready (LSR bit 0 is set)
	ldr r2, =UART_AUX_MU_IO_REG
	ldr r0, [r2]
// write character to IO register
	mov pc, lr


//******************************************************

/* Read from UART until newline is encountered
*
r0 - buffer
*
r1 - buffer length
* Returns:
*
r0 - number of chars read
*/
readLineUART:
	push {r4, r5, r6, lr}
	buff .req r4
	maxlen .req r5
	count .req r6
	mov buff, r0
	mov maxlen, r1
	mov count, #0
break1:
readLoop$:
	teq count, maxlen
	beq readLoopEnd$
// exit read loop if count == maxlen
	bl getChar
  // get a character from UART line
	bl putChar
  // echo character back down the line
	strb r0, [buff]
// store the character in the buffer
	add count, #1 
// increment count
	add buff, #1
// increment buffer pointer
	teq r0, #'\r'
	bne readLoop$
// loop if character read is not carriage return (\r)
break2:
	mov r0, #'\n'
	bl putChar
	sub buff, #1
	mov r0, #0
	strb r0, [buff]
// write a zero over carriage return in buffer
readLoopEnd$:
	sub r0, count, #1
// return count - 1
	pop {r4, r5, r6, pc}
    mov    pc, lr
//*********************************************************
/* Write a string to the UART line
* r0 - string pointer
* r1 - length
*/
writeStringUART:
	push {r4, r5, lr}
	string .req r4
	length .req r5
	mov string, r0
	mov length, r1

writeLoop$:
	cmp length, #0
	ble writeLoopEnd$

	ldr r0, [string]
	bl putChar

	add string, #1
	sub length, #1

	b writeLoop$

writeLoopEnd$:
	pop {r4, r5, pc}
    mov    pc, lr
//*********************************************************
/*clearBuffer:
	push {r0}			//push buffer
	buff .req r0
	mov r9, #0			//set counter to 0

clearLoop:
	cmp r9, #256
	beq endClear
	mov r0, #0
	add buff, #1
	add r9, #1
	b clearLoop
	
endClear:
	pop {r0, pc}
	mov pc, lr
*/

//*********************************************************
.section .data
.EQU UART_AUX_MU_LSR_REG, 0x20215054 //Line status register
.EQU UART_AUX_MU_IO_REG, 0x20215040 //IO register
buff:
.ascii "/n"
.rept	256
.byte	0
.endr

echo:
.ascii	"echo"

