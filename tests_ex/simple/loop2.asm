.text

;loop_test:
;j loop_test

li t0, 128

loop_color:
	li a0, 0x04000000
	li a1, 0x88000
	loop_write:
		addiu a0, a0, 1
		addiu a1, a1, -1
		sb t0, 0(a0)
	bne a1, zr, loop_write
	nop
addi t0, t0, 1
syscall 0x2147 ; sceDisplay.sceDisplayWaitVblankStart
j loop_color
nop
