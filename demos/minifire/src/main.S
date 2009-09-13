# Mini fire demo (c) TyRaNiD 2k6

	.set noreorder
	.set noat

#ifdef BUILD_V1
#include "syscallv1.h"
#else
#include "syscallv15.h"
#endif

#define MAX_X 512
#define MAX_Y 91

.section .rodata.sceModuleInfo
	.global _info
_info:
	.hword 0x0000
	.byte  1, 1
_name:
	.asciz "UNP"

	.global _start
_start:
	# 7 dirty dirty Instructions
	lui	   $s0, %hi(_name)
	addiu  $a0, $s0, %lo(_name)
	addiu  $a1, $s0, %lo(thread)
	addiu  $a2, $zero, 20
	lui    $a3, 0x2
	lui    $t0, 0x8000
	move   $t1, $zero
	.word  0
	.word  0
	.word  0
	.word  0

# Create Thread
	syscall _sceKernelCreateThread
	move $a0, $v0
	move $a1, $zero
	move $a2, $zero
# Start Thread
	syscall _sceKernelStartThread
	move $a0, $zero
# Exit Thread
	syscall _sceKernelExitThread

# Main thread procedure
# s0 - Frame Buffer
# s1 - p1
# s2 - p2

thread:
	# Allocate stack frame for random number gen and controller
	addiu $sp, $sp, -(2512+16)
	move  $a0, $sp
	# We leave $a1 as what ever random value it starts with, probably 0
	syscall _sceKernelUtilsMt19937Init

# Load addresses of the buffers
	lui   $s1, 0x08A0
	lui   $s2, 0x08B0

# Load VRAM address
	lui  $s0, 0x4400
	move $a0, $zero
	li   $a1, 480
	li   $a2, 272
	syscall _sceDisplaySetMode

# Clear buffer
	move $v0, $s1
	li   $t0, (MAX_X*MAX_Y)
clear:
	sb   $zero, 0($v0)
	addiu $t0, $t0, -1
	bgez  $t0, clear
	addiu $v0, 1

mainloop:

# Setup random line
# s3 end position
# s4 current position
	ori   $s4, $s1, (MAX_Y-1)*MAX_X
	addiu $s3, $s4, (MAX_X-1)
setup:
	move  $a0, $sp
	syscall _sceKernelUtilsMt19937UInt
	addiu $s4, $s4, 1
	sltu  $v1, $s4, $s3
	bnez  $v1, setup
	sb    $v0, 0($s4)

# Add a random point, create abit of interest
	li    $s5, 0x1FE
	move  $a0, $sp
	syscall _sceKernelUtilsMt19937UInt
	li    $v1, MAX_Y-2
	divu  $v0, $v1
# Pull out remainder, quotient already in $v0
	mfhi  $v1
	addiu $v1, $v1, 1
	sll   $v1, $v1, 9
	add   $s4, $v1, $s1
# Pull out quotient
	and   $v0, $v0, $s5
	addiu $v0, $v0, 1
	add   $s4, $s4, $v0
	sb    $s5, 0($s4)

# Merge values
# t0 current y
# t1 current x
# t2 end x
# t3 p2
	li    $t0, MAX_Y-2
	ori   $t1, $s1, (MAX_Y-2)*MAX_X
	ori   $t3, $s2, (MAX_Y-2)*MAX_X
merge_y:
	addiu $t2, $t1, (MAX_X-2)
merge_x:
# Accumulate (y+1,x-1),(y+1,x),(y+1,x+1),(y,x)
	lbu   $a0, MAX_X($t1)
	lbu   $a1, MAX_X+1($t1)
	addu  $a0, $a0, $a1
	lbu   $a1, MAX_X+2($t1)
	addu  $a0, $a0, $a1
	lbu   $a1, 1($t1)
	addu  $a0, $a0, $a1
# Get average
	srl   $a0, $a0, 2
# Decrement if > 0
	bgtzl $a0, 1f
	addiu $a0, $a0, -1
1:
	sb    $a0, 1($t3)

	addiu $t1, $t1, 1
	sltu  $v0, $t1, $t2
	bnez  $v0, merge_x
	addiu $t3, $t3, 1

	addiu $t0, $t0, -1
	addiu $t3, $t3, -((MAX_X*2)-2)
	bgtz  $t0, merge_y
	addiu $t1, $t1, -((MAX_X*2)-2)

# Copy loop, put data to VRAM
# $t0 current y
# $t2 current p2
# $t3 end p2 for this line
# $a0 frame buffer

# Do double buffering (not really necessary but hey)
	li   $t0, 1024*1024
	xor  $s0, $s0, $t0

	move $v0, $s0
	move $t0, $zero
	move $t2, $s2
	move $a0, $s0
copy_y_loop:
	addiu $t3, $t2, MAX_X
copy_x_loop:
	lbu   $v0, 0($t2)
	sw    $v0, 0($a0)
	sw    $v0, (MAX_X*4)($a0)
	sw    $v0, (MAX_X*8)($a0)
	addiu $t2, $t2, 1
	sltu  $v1, $t2, $t3
	bnez  $v1, copy_x_loop
	addiu $a0, $a0, 4
	addiu $t0, $t0, 1
	sltiu $v0, $t0, (MAX_Y-1) 
	bnez  $v0, copy_y_loop
	addiu $a0, $a0, (8*MAX_X)

# Check the pad to see if we want to exit
# Any button will do
	addiu $a0, $sp, 2512
	li    $a1, 1
	syscall _sceCtrlPeekBufferPositive
	lw    $t0, 2516($sp)
	bnezl $t0, ctrl
	syscall _sceKernelExitGame
ctrl:

# Delay
	syscall _sceDisplayWaitVblankStart
# Flip buffers
	move $a0, $s0
	li   $a1, 512
	li   $a2, 3
	li   $a3, 1
	syscall _sceDisplaySetFrameBuf

# Swap buffers
	move  $t0, $s1
	move  $s1, $s2

	j     mainloop
	move  $s2, $t0
