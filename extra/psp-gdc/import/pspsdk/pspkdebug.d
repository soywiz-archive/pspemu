/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspkdebug.h - Interface to KDebugForKernel.
 *
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 *
 * $Id: pspkdebug.h 1971 2006-07-17 19:43:52Z tyranid $
 */

module pspsdk.pspkdebug;

import pspsdk.pspkerneltypes; 

/** @defgroup Kdebug Interface to the KDebugForKernel library.
 */

extern (C):

/** @addtogroup Kdebug Interface to the KDebugForKernel library. */
/*@{*/

/** Typedef for the debug putcharacter handler */
alias void function(ushort* args, uint ch) PspDebugPutChar;
//typedef void (*PspDebugPutChar)(ushort* args, uint ch);

/**
 * Register a debug put character handler
 *
 * @param func - The put character function to register.
 */
void sceKernelRegisterDebugPutchar(PspDebugPutChar func);

/**
 * Get the debug put character handler
 *
 * @return The current debug putchar handler
 */
PspDebugPutChar sceKernelGetDebugPutchar();

/**
 * Kernel printf function.
 *
 * @param format - The format string.
 * @param ... - Arguments for the format string.
 */
void Kprintf(/*const*/ char *format, ...) /*__attribute__((format(printf, 1, 2)))*/;

/*@}*/
