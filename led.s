//Richard Huynh			UCID: 10099642
//Melissa Ta			UCID: 10110850
//Yin-Li (Emily) Chow           UCID: 10103742
.globl   startinput

startinput:
    b    begin             //Branch to begin
    .section .text

//This will turn the led on
.globl ledOn
ledOn:
    bl begin               //Branch to begin
    ldr    r6, =0x20200028 //Clearing register 0 address
    mov    r7, #0x00010000 //Move 1 over 16 times
    str    r7, [r6]        //Write to clear register 0
    bl go                  //Branch to go in main.s

//This will turn off the led
.globl ledOff
ledOff:
    bl begin               //Branch to begin
    ldr    r6, =0x2020001C //Setting regiser 0 address
    mov    r7, #0x00010000 //Move 1 over 16 times
    str    r7, [r6]        //Write to set register 0
    bl go                  //Branch to go in main.s


haltLoop$:
    b    haltLoop$

//************************************************

begin:
    ldr    r6, =0x20200004 //Get Function Select 1 address
    ldr    r7, [r6]        //Load value of address into r7
    mov    r8, #0b111      //Move bit mask 111 to r8
    bic    r7, r8, lsl #18 //Clear bits 18-20. Store into r7

    mov    r8, #0b001      //Move value mask 001 into r8
    orr    r7, r8, lsl #18 //Set value mask into bits 18-20

    str    r7, [r6]        //Store the register into memory
	
    mov    pc, lr          //Branch back to calling code   
