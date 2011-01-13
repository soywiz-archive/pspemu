/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * main.c - Basic sample to demonstrate some fileio functionality.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 * Copyright (c) 2005 Jim Paris <jim@jtan.com>
 *
 * $Id: main.c 1175 2005-10-20 15:41:33Z chip $
 */
import pspsdk.all;

import std.file; // @TODO: Fix!

import std.string;

//char[] getcwd() { return "/"; }
//void chdir(char[]) { }

version (BUILD_INFO) {
	pragma(MODULE_NAME, "CwdTest");
	pragma(PSP_EBOOT_TITLE, "CwdTest");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER | THREAD_ATTR_VFPU);
	pragma(PSP_FW_VERSION, 150);
}

void _try(/*const*/ char *dest)
{
	pspDebugScreenPrintf("%16s --> ", dest);
	try {
		chdir(toString(dest));
		pspDebugScreenPrintf("%s\n", std.string.toStringz(getcwd()));
	} catch {
		pspDebugScreenPrintf("(chdir error)\n");
	}
}

int main()
{
	pspDebugScreenInit();
	SetupCallbacks();

	pspDebugScreenPrintf("Working Directory Examples\n");
	pspDebugScreenPrintf("Initial dir: %s\n\n", std.string.toStringz(getcwd()));

	pspDebugScreenPrintf("%16s --> %s\n", "chdir() attempt", "resulting getcwd()");
	pspDebugScreenPrintf("%16s --> %s\n", "---------------", "------------------");
	_try("");		   /* empty string                */
	_try("hello");		   /* nonexistent path            */
	_try("..");		   /* parent dir                  */
	_try("../SAVEDATA");	   /* parent dir and subdir       */
	_try("../..");		   /* multiple parents            */
	_try(".");		   /* current dir                 */
	_try("./././//PSP");        /* current dirs, extra slashes */
	_try("/PSP/./GAME");	   /* absolute with no drive      */
	_try("/");                  /* root with no drive          */
	_try("ms0:/PSP/GAME");      /* absolute with drive         */
	_try("flash0:/");           /* different drive             */
	_try("ms0:/PSP/../PSP/");   /* mixed                       */

	pspDebugScreenPrintf("\nAll done!\n");

	return 0;
}
