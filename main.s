//Richard Huynh			UCID: 10099642
//Melissa Ta			UCID: 10110850
//Yin-Li (Emily) Chow	        UCID: 10103742
.section .init
.globl starting

starting:
	b go                    //Branch to go
	.section .text

.globl go    
go:
	mov sp, #0x8000
	bl EnableJTAG

	bl initializeUART       //Initialize UART
	mov r0, #0xA 	        //Start of beginning of prompt
	bl putChar              //Branch to putChar
	mov r0, #0xD            //Set carriage return
	bl putChar              //Branch to putChar
	mov r0, #0x3E           //Set ">"
	bl putChar              //Branch to putChar
	mov r0, #0x20           //Set "<space>"
	bl putChar              //End of setting up prompt
      
	ldr r0, =buff           //Loading buffer address
	mov r1, #256            //Setting the max of buffer 
	
	
	bl readLineUART         //Read input lines
	
	mov r10, r0             //Set max count for characters inputted

	mov r0, #0xA            //Adds a space 
	bl putChar              //Prints out space
	
	ldr r0, =buff           //Get address of buffer
	bl checkInput           //Branch to checkInput

	b go                    //Branch back to go

haltLoop$:
	b haltLoop$             // end program
   
//******************************************************
//This is basically for printing the characters
/* Put a character in the UART transmitter FIFO
r0 - char to write(only lower byte used)
Returns:
r0 - character written */

putChar:
	ldr r2, =UART_AUX_MU_LSR_REG //Get line status register
putWaitLoop$:
	ldr r1, [r2]                 //Get value at r2 address and put into r1
	tst r1, #0x20                //Test bit 5
	beq putWaitLoop$             //Wait until LSR bit 5 (transmitter empty) is set
	//i.e. wait until line can accept at least one byte
	ldr r2, =UART_AUX_MU_IO_REG  //Get address of IO register
	str r0, [r2]                 //Write character to the IO register
	
	mov pc, lr                   //Branch back to calling code
	
//******************************************************

getChar:
	ldr r2, =UART_AUX_MU_LSR_REG //Get line status reg
getWaitLoop$:
	ldr r1, [r2]                 //Get value at r2 address and put into r1
	tst r1, #0x1                 //Test bit 0  
	beq getWaitLoop$             //Wait until data is ready (LSR bit 0 is set)
	ldr r2, =UART_AUX_MU_IO_REG  //Get address of UART_AUX_MU_IO_REG
	ldr r0, [r2]                 //Write character to IO register
	mov pc, lr                   //Branch back to calling code


//******************************************************
/* Read from UART until newline is encountered
r0 - buffer
r1 - buffer length
Returns:
r0 - number of chars read */

readLineUART:
	push {r4, r5, r6, lr}        //Push r4, r5, r6, and lr onto stack
	buff .req r4                 //Set buff = r4
	maxlen .req r5               //Set maxlen = r5
	count .req r6                //Set count = r6
	mov buff, r0                 //Move buffer address (r0) into buff
	mov maxlen, r1               //Move r1 (max length of string) into maxlen
	mov count, #0                //Set count to #0

readLoop$:
	teq count, maxlen            //Test count and maxlen
	beq readLoopEnd$             //Branch out if count == maxlen
	bl getChar                   //Get a character from UART line
	bl putChar                   //Echo character back down the line
	strb r0, [buff]              //Store the character in the buffer
	add count, #1                //Increment count by 1
	add buff, #1                 //Increment buffer pointer by 1
	teq r0, #'\r'                //Test r0 to "\r"
	bne readLoop$                //Loop if character read is not carriage return "\r"

	mov r0, #'\n'                //Move "\n" into r0
	bl putChar                   //Branch to putChar
	sub buff, #1                 //Subtract buff by 1
	mov r0, #0                   //Move #0 into r0
	strb r0, [buff]              //Write a zero over carriage return in buffer

readLoopEnd$:
	sub r0, count, #1            //Return count - 1
	pop {r4, r5, r6, pc}         //Pop original values of r4, r5, r6, and pc out of stack
	mov pc, lr                   //Branch back to calling code
//*********************************************************
/* Write a string to the UART line
* r0 - string pointer
* r1 - length
*/
writeStringUART:
	push {r4, r5, lr}            //Push r4, r5, and lr onto the stack
	string .req r4               //Set string = r4
	length .req r5               //Set length = r5
	mov string, r0               //Move buffer address (r0) into string
	mov length, r10              //Move length of string (r10) into length
	add length, #1               //Add length by 1
	add string, #6               //Add string by 6

writeLoop$:                         
	cmp length, #0               //Compare length to 0
	ble writeLoopEnd$            //Branch if length < 0
	ldr r0, [string]             //Get value at address of string and put into r0
	bl putChar                   //Branch to putChar
	mov	r1, #0x0             //Move 0 into r1
	strb r1, [string]            //Store r1 into address of string  
	add string, #1               //Increment string by 1
	sub length, #1               //Decrement length by 1
	b writeLoop$                 //Branch back to writeLoop$

writeLoopEnd$:
	pop {r4, r5, pc}             //Pop original values of r4, r5, and pc
	mov pc, lr                   //Branch back to calling code

//*********************************************************
//Check the input if it corresponds to correct commands
checkInput:
/*r0 - string pointer
* r1 - length
*/
	push {r4, r5, lr}            //Push r4, r5, and lr onto stack
	string .req r4               //Set string = r4
	length .req r5               //Set length = r5
	mov string, r0               //Move buffer address (r0) into string
	mov length, r5               //Move length of string (r5) into length
	mov r3, #0                   //Move #0 into r3

	ldrb r1, [string, r3]        //Get first charcter from string address
	mov r2, #0x6C                //Move "l" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne echo                     //Branch to echo if r1 != "l"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get second character from string address
	mov r2, #065                 //Move "e" into r2
	cmp r1, r2                   //Compare r1 and r2
 	bne invalid                  //Branch to invalid if r1 != "e"
	add r3, #1                   //Increment r3 by 1

	ldrb r1, [string, r3]        //Get third character from string address
	mov r2, #0x64                //Move "d" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "d"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get fourth character from string address
	mov r2, #020                 //Move " " into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != " "
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get fifth character from string address
	mov r2, #0x6F                //Move "o" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "o"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get sixth character from string address
	mov r2, #0x6E                //Move "n" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne off                      //Branch to off if r1 != "n"
	add r3, #1                   //Increment r3 by 1
	
	cmp r3, r10                  //Compare r3 and r10
	beq callLEDOn                //Branch to callLEDOn if r3 == r10
	b invalid                    //Branch to invalid (assuming that there are more characters afterwards)

off:
	mov r2, #066                 //Move "f" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "f"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get seventh character from string address  
	mov r2, #0x66                //Move "f" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "f"
	add r3, #1                   //Increment r3 by 1
	
	cmp r3, r10                  //Compare r3 and r10
	beq callLEDOff               //Branch to callLEDOff if r3 == r10
	b invalid	             //Branch to invalid (assuming that there are more characters afterwards)

invalid:	
	ldr    r0, =errorMessage     //Get address of errorMessage
	bl     writeErrorUART        //Branch to writeErrorUART
	b go                         //Branch to go

callLEDOn:
	bl ledOn                     //Branch to ledOn in led.s
	b go                         //Branch to go

callLEDOff:
	bl ledOff                    //Branch to ledOff in led.s
	b go                         //Branch to go

//*********************************************************
echo: 
	ldrb r1, [string, r3]        //Get first character from string address
	mov r2, #0x65                //Move "e" into r2
	cmp r1, r2                   //Compare r1 to r2
	bne invalid                  //Branch to invalid if r1 != "e"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get second character from string address
	mov r2, #0x63                //Move "c" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "c"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get third character from string address   
	mov r2, #0x68                //Move "h" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "h"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get fouth character from string address
	mov r2, #06F                 //Move "o" into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != "o"
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get fifth character from string address
	mov r2, #0x20                //Move " " into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != " "
	add r3, #1                   //Increment r3 by 1
	
	ldrb r1, [string, r3]        //Get sixth character from string address
	mov r2, #0x22                //Move """ into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != """
		
	mov r3, r10                  //Move value of r10 into r3
	sub r3, #1                   //Subtract r3 by 1
	ldrb r1, [string, r3]	     //Get last character from string address
	mov r2, #0x22                //Move """ into r2
	cmp r1, r2                   //Compare r1 and r2
	bne invalid                  //Branch to invalid if r1 != """

writing:
	b writeStringUART            //Branch to writeStringUART to write to UART line

//*********************************************************
//This is to display an error message if checkInput does not match commands
//or echo arguement requirements
.globl writeErrorUART
writeErrorUART:
	push {r4, r5, lr}           //Push r4, r5, and lr onto the stack
	errorString .req r4         //Set errorString = r4
	length .req r5              //Set length = r5

	mov    errorString, r0      //Move buffer address (r0) into errorString
	mov    length, #30          //Move #30 into length

writeErrorLoop:
	cmp length, #0              //Compare the length to 0
	ble writeErrorLoopEnd       //Branch to writeErrorLoopEnd if length < 0

	ldrb r0, [errorString], #1  //Get next charcter into r0 by adding errorString by 1
	bl putChar                  //Branch to putChar
	
	sub length, #1              //Decrement the length by 1

	b writeErrorLoop            //Branch to writeErrorLoop

writeErrorLoopEnd:
	pop	{r4, r5, pc}        //Pop r4, r5, and pc. Go back to calling code

//*********************************************************
.section .data
.EQU UART_AUX_MU_LSR_REG, 0x20215054 //Line status register
.EQU UART_AUX_MU_IO_REG, 0x20215040  //IO register
buff:
	.rept	256   //Set 256
	.byte	0     //Set 0
	.endr
errorMessage:	.ascii "error: invalid input\r"    //Error message
