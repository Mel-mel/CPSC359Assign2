.globl   startinput

startinput:
    b    begin
    .section .text

.globl ledOn
ledOn:
	bl begin    
	//The three lines below will turn the led on
    ldr    r6, =0x20200028
    mov    r7, #0x00010000
    str    r7, [r6]
    bl go

.globl ledOff
ledOff:
	bl begin
    //The three lines below will turn the led off
    ldr    r6, =0x2020001C
    mov    r7, #0x00010000
    str    r7, [r6]
    bl go   


haltLoop$:
    b    haltLoop$

//************************************************

begin:
    ldr    r6, =0x20200004
    ldr    r7, [r6]
    mov    r8, #0b111
    bic    r7, r8, lsl #18

    mov    r8, #0b001
    orr    r7, r8, lsl #18

    str    r7, [r6]
	
	mov    pc, lr   
