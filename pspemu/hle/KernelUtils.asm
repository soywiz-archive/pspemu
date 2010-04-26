.text 0x08000000
	syscall 0x2015   ; ThreadManForUser.sceKernelSleepThreadCB
	syscall 0x1003   ; _pspemuHLEInvalid. Should not be executed.
	
.text 0x08000010
	ininite_loop:
		j ininite_loop
		nop
	syscall 0x1003   ; _pspemuHLEInvalid. Should not be executed.

.text 0x08000200 ; sceKernelExitDeleteThread
	li a0, 0
	syscall 0x2071   ; sceKernelExitThread
	syscall 0x1003   ; _pspemuHLEInvalid. Should not be executed.
	
; Utility. Returning from an user callback.
; // _pspemuHLEInterruptCallbackReturn
.text 0x08000300
	syscall 0x1002
	syscall 0x1003   ; _pspemuHLEInvalid. Should not be executed.


