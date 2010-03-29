#include <pspkernel.h>
#include <stdio.h>
#include <stdarg.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>

PSP_MODULE_INFO("TEST_SPRINTF", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

char test_buffer2[] = "pspemupspemupspemupspemupspemupspemu\0";
char test_buffer[1024] = "pspemupspemupspemupspemupspemupspemu\0";

//void startTracing() { asm("syscall 0x230B"); }
//void stopTracing()  { asm("syscall 0x230C"); }
#define startTracing() { asm("syscall 0x230B"); }
#define stopTracing()  { asm("syscall 0x230C"); }

#define assert(v) { if (!(v)) { asm("break"); } }

//#define emitToString 1
#define emitToString 0

char *itoa(int v, char *ptr, int radix);

/*
char *itoa(int v, char *ptr, int radix) {
	char *ptr0 = ptr;
	const char *digits = "0123456789ABCDEF";
	
	if (v < 0) {
		*ptr++ = '-';
		v = -v;
	}
	
	if (v == 0) {
		*ptr++ = '0';
	} else {
		int v2 = v;
		int mult = 1;
		while ((v2 /= radix) > 0) mult *= radix;

		while (mult > 0) {
			*ptr++ = digits[(v / mult) % radix];
			mult /= radix;
		}
	}
	*ptr++ = 0;
	*ptr++ = 0;
	return ptr0;
}*/

void emitInt(int v) {
	asm("syscall 0x2308");
	if (emitToString) {
		char temp[16];
		strcat(test_buffer, "emitInt(");
		strcat(test_buffer, itoa(v, temp, 10));
		strcat(test_buffer, ")\n");
	}
}
void emitFloat(float v) {
	asm("syscall 0x2309");
	if (emitToString) strcat(test_buffer, "emitFloat()\n");
}
void emitString(char *v) {
	asm("syscall 0x230A");
	if (emitToString) { strcat(test_buffer, "emitString(\""); strcat(test_buffer, v); strcat(test_buffer, "\")\n"); }
}
void emitDouble(double d) {
	char temp[32];
	int *pi = (int *)&d;
	sprintf(temp, "%08X%08X", pi[0], pi[1]);
	emitString(temp);
}

void testDouble(double d) {
	while (d >= 1.0) d /= 10.0;
	int n;
	long l;
	for (n = 0; n < 3; n++) {
		d *= 10.0;
		l = (long)d;
		//emitDouble(d);
		emitInt(l);
		d -= l;
	}
}

typedef union double_union {
	double d;
	unsigned int i[2];
} double_union;

void testDoubleSimple() {
	long l = 3;
	double_union du;
	du.i[0] = 0xFFFFFFFE;
	du.i[1] = 0x400FFFFF;
	//startTracing();
	{
		du.d -= l;
		du.d *= 10.0;
		l = (long)du.d;
		//emitDouble(du.d);
		//emitDouble(du.d);
		emitInt(l);
	}
	//stopTracing();
}

int main() {
	{
		testDoubleSimple();
		testDouble(240.0);
	}
	assert(0);
	return 0;
}