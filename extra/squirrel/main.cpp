#include <pspkernel.h>
#include <psprtc.h>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h> 

#include <squirrel.h> 
#include <sqstdio.h> 
#include <sqstdaux.h> 

PSP_MODULE_INFO("squirrel", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

void printfunc(HSQUIRRELVM vm, const SQChar *s, ...) {
	char temp[1024];
	va_list vl;
	va_start(vl, s);
	vsprintf(temp, s, vl);
	va_end(vl);
	pspDebugScreenPrintf("%s", temp);
}

int main(int argc, char* argv[])  { 
	HSQUIRRELVM vm = sq_open(1024);

	pspDebugScreenInit();

	sq_pushroottable(vm);
	sqstd_register_iolib(vm); 
	sqstd_seterrorhandlers(vm);

	sq_setprintfunc(vm, printfunc, printfunc);

	sq_pushroottable(vm);
	sqstd_dofile(vm, _SC("main.nut"), SQFalse, SQTrue);

	sq_pop(vm, 1);
	sq_close(vm); 

	return 0; 
} 
