#include <pspkernel.h>
#include <stdio.h>
#include <stdarg.h>
#include <_ansi.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>

PSP_MODULE_INFO("TEST_SPRINTF", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

void emitString  (char *v) { asm("syscall 0x230A"); }
void startTracing()        { asm("syscall 0x230B"); }
void stopTracing()         { asm("syscall 0x230C"); }

int sprintf(char *str, const char *fmt, ...) {
	int ret;
	va_list ap;
	FILE f;

	f._flags = __SWR | __SSTR;
	f._bf._base = f._p = (unsigned char *) str;
	f._bf._size = f._w = INT_MAX;
	f._file = -1;  /* No file. */
	va_start (ap, fmt);
	ret = _vfprintf_r (_REENT, &f, fmt, ap);
	va_end (ap);
	*f._p = 0;
	return (ret);
}

char global_buffer[31] = "soywizsoywizsoywizsoywizsoywiz";

int main() {
	startTracing();
	{
		sprintf(global_buffer, "%f", 240.0);
	}
	stopTracing();
	emitString(global_buffer);
	//asm("break");
	return 0;
}