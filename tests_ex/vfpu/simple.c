/*
FPU Test. Originally from jpcsp project:
http://code.google.com/p/jpcsp/source/browse/trunk/demos/src/fputest/main.c
Modified to perform automated tests.
*/

//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g simple.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -o simple.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" simple.elf

#include <pspkernel.h>
#include "../common/emits.h"

PSP_MODULE_INFO("vfpu test", 0, 1, 1);

PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | PSP_THREAD_ATTR_VFPU);

void __attribute__((noinline)) vcopy(ScePspFVector4 *v0, ScePspFVector4 *v1) {
	asm volatile (
		"lv.q   C100, %1\n"
		"sv.q   C100, %0\n"

		: "+m" (*v0) : "m" (*v1)
	);
}

void __attribute__((noinline)) vdotq(ScePspFVector4 *v0, ScePspFVector4 *v1, ScePspFVector4 *v2) {
	asm volatile (
		"lv.q   C100, %1\n"
		"lv.q   C200, %2\n"
		"vdot.q S000, C100, C200\n"
		"sv.q   C000, %0\n"

		: "+m" (*v0) : "m" (*v1), "m" (*v2)
	);
}

void __attribute__((noinline)) vsclq(ScePspFVector4 *v0, ScePspFVector4 *v1, ScePspFVector4 *v2) {
	asm volatile (
		"lv.q   C100, %1\n"
		"lv.q   C200, %2\n"
		"vscl.q C300, C100, S200\n"
		"sv.q   C300, %0\n"

		: "+m" (*v0) : "m" (*v1), "m" (*v2)
	);
}

ScePspFVector4 v0, v1, v2;

void initValues() {
	// Reset output values
	v0.x = 1001;
	v0.y = 1002;
	v0.z = 1003;
	v0.w = 1004;

	v1.x = 17;
	v1.y = 13;
	v1.z = -5;
	v1.w = 11;

	v2.x = 3;
	v2.y = -7;
	v2.z = -15;
	v2.w = 19;
}

int main(int argc, char *argv[]) {
	initValues();
	vcopy(&v0, &v1);
	emitFloat(v0.x);
	emitFloat(v0.y);
	emitFloat(v0.z);
	emitFloat(v0.w);

	initValues();
	vdotq(&v0, &v1, &v2);
	emitFloat(v0.x);

	initValues();
	vsclq(&v0, &v1, &v2);
	emitFloat(v0.x);
	emitFloat(v0.y);
	emitFloat(v0.z);
	emitFloat(v0.w);

	return 0;
}