module pspsdk.pspkernel;

/*
#include <pspuser.h>
#include <pspiofilemgr_kernel.h>
#include <psploadcore.h>
#include <pspstdio_kernel.h>
#include <pspsysreg.h>
#include <pspkdebug.h>
#include <pspintrman_kernel.h>
#include <pspmodulemgr_kernel.h>
*/

/**
 * Set the $pc register to a kernel memory address.
 *
 * When the PSP's kernel library stubs are called, they expect to be accessed
 * from the kernel's address space.  Use this function to set $pc to the kernel
 * address space, before calling a kernel library stub.
 */
/*
#define pspKernelSetKernelPC()  \
{     \
	__asm__ volatile (      \
	"la     $8, 1f\n\t"     \
	"lui    $9, 0x8000\n\t" \
	"or     $8, $9\n\t"     \
	"jr     $8\n\t"         \
	" nop\n\t"              \
	"1:\n\t"                \
	: : : "$8", "$9");      \
	sceKernelIcacheClearAll(); \
}
*/

/**
 * Set the $pc register to a user memory address.
 *
 */
/*
#define pspKernelSetUserPC()  \
{     \
	__asm__ volatile (      \
	"la     $8, 1f\n\t"     \
	"li     $9, 0x7FFFFFFF\n\t" \
	"and    $8, $9\n\t"     \
	"jr     $8\n\t"         \
	" nop\n\t"              \
	"1:\n\t"                \
	: : : "$8", "$9");      \
	sceKernelIcacheClearAll(); \
}
*/