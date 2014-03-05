.section .init
.globl starting

starting:
    b go
    .section .text

.globl go    
go:
    mov sp, #0x8000
    bl EnableJTAG

    bl	initializeUART
    mov r0, #0xA			//start of beginning of prompt
    bl putChar
    mov r0, #0xD
    bl putChar
    mov r0, #0x3E			
	bl putChar
	mov r0, #0x20
	bl putChar				//end of setting up prompt
      
    ldr r0, =buff			//loading buffer
	mov	r1,	#256			//setting max of buffer 
	
	
	bl readLineUART			//read input lines
	
	mov	r10, r0				//set max count for characters inputted

	mov	r0,	#0xA			//adds a space 
	bl putChar				//prints out space
	
	ldr r0, =buff
	bl checkInput

	b go

haltLoop$:
    b haltLoop$                 // end program
   
//******************************************************
//This is basically for printing the characters
/* Put a character in the UART transmitter FIFO
r0 - char to write(only lower byte used)
Returns:
r0 - character written */

putChar:
	ldr r2, =UART_AUX_MU_LSR_REG // line status register
putWaitLoop$:
	ldr r1, [r2]
	tst r1, #0x20 				// test bit 5
	beq putWaitLoop$			// wait until LSR bit 5 (transmitter empty) is set
// i.e., wait until line can accept at least one byte
	ldr r2, =UART_AUX_MU_IO_REG // IO register
	str r0, [r2] 				// write character to the IO register
	
	mov pc, lr
	
//******************************************************

getChar:
	ldr r2, =UART_AUX_MU_LSR_REG 	// line status reg
getWaitLoop$:
	ldr r1, [r2]
	tst r1, #0x1 // test bit 0
	beq getWaitLoop$				// wait until data is ready (LSR bit 0 is set)
	ldr r2, =UART_AUX_MU_IO_REG
	ldr r0, [r2]					// write character to IO register
	mov pc, lr


//******************************************************

/* Read from UART until newline is encountered
r0 - buffer
r1 - buffer length
Returns:
r0 - number of chars read */

readLineUART:
	push {r4, r5, r6, lr}
	buff .req r4
	maxlen .req r5
	count .req r6
	mov buff, r0
	mov maxlen, r1
	mov count, #0

readLoop$:
	teq count, maxlen
	beq readLoopEnd$			// exit read loop if count == maxlen
	bl getChar					// get a character from UART line
	bl putChar					// echo character back down the line
	strb r0, [buff]				// store the character in the buffer
	add count, #1 				// increment count
	add buff, #1				// increment buffer pointer
	teq r0, #'\r'
	bne readLoop$				// loop if character read is not carriage return (\r)

	mov r0, #'\n'
	bl putChar
	sub buff, #1
	mov r0, #0
	strb r0, [buff]				// write a zero over carriage return in buffer

readLoopEnd$:
	sub r0, count, #1			// return count - 1
	pop {r4, r5, r6, pc}
    mov pc, lr
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
	mov length, r10
	add length, #1
	add string, #6

writeLoop$:
	cmp length, #0
	ble writeLoopEnd$
	ldr r0, [string]
	bl putChar
	mov	r1, #0x0
	strb r1, [string]
	add string, #1
	sub length, #1
	b writeLoop$

writeLoopEnd$:
	pop {r4, r5, pc}
    mov pc, lr

//*********************************************************
/*Time to do some ascii checking broz. Likely we would do this 
during the reading/processing of the string*/

checkInput:
/*r0 - string pointer
* r1 - length
*/
	push {r4, r5, lr}
	string .req r4
	length .req r5
	mov string, r0
	mov length, r5
	mov r3, #0

	ldrb r1, [string, r3]
	mov r2, #0x6C				// "l"
	cmp r1, r2
	bne echo
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x65				// "e"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x64				// "d"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x20				// " "
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x6F				// "o"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x6E				// "n"
	cmp r1, r2
	bne off
	add r3, #1
	cmp     r3, r10
    beq     callLEDOn
	b invalid

off:
	mov r2, #0x66				// "f"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x66				// "f"
	cmp r1, r2
	bne invalid
	add r3, #1
	cmp     r3, r10
    beq     callLEDOff
	b invalid	

invalid:	
    ldr    r0, =errorMessage
    bl     writeErrorUART
	b go

callLEDOn:
	bl ledOn
	b go

callLEDOff:
	bl ledOff
	b go

//*********************************************************
echo: 
	ldrb r1, [string, r3]
	mov r2, #0x65				// "e"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x63				// "c"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x68				// "h"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x6F				// "o"
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x20				// " "
	cmp r1, r2
	bne invalid
	add r3, #1
	ldrb r1, [string, r3]
	mov r2, #0x22				// """
	cmp r1, r2
	bne invalid
		
	mov r3, r10
	sub r3, #1
	ldrb r1, [string, r3]	
	mov r2, #0x22				// """
	cmp r1, r2
	bne invalid
	b	writing

writing:
	b writeStringUART

//*********************************************************

.globl writeErrorUART
writeErrorUART:
	push {r4, r5, lr}
    errorString .req r4
    length .req r5

    mov    errorString, r0
    mov    length, #30

writeErrorLoop:
	cmp length, #0
	ble writeErrorLoopEnd

	ldrb r0, [errorString], #1
	bl putChar
	

	sub length, #1

	b writeErrorLoop

writeErrorLoopEnd:
	pop	{r4, r5, pc}

//*********************************************************
.section .data
.EQU UART_AUX_MU_LSR_REG, 0x20215054 //Line status register
.EQU UART_AUX_MU_IO_REG, 0x20215040 //IO register
buff:
	.rept	256
	.byte	0
	.endr


errorMessage:	.ascii "error: invalid input\r"
