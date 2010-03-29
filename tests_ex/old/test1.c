#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
//#include <assert.h>

#include <pspctrl.h>
#include <pspgu.h>
#include <psprtc.h>

PSP_MODULE_INFO("Test1", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

#define assert(v) { if (!(v)) { asm("break"); } }
void emitInt   (int   v) { asm("syscall 0x2308"); }
void emitFloat (float v) { asm("syscall 0x2309"); }
void emitString(char *v) { asm("syscall 0x230A"); }

unsigned int crc_tab[256];

unsigned int chksum_crc32(unsigned char *block, unsigned int length) {
	register unsigned long crc;
	unsigned long i;
	crc = 0xFFFFFFFF;
	for (i = 0; i < length; i++) { crc = ((crc >> 8) & 0x00FFFFFF) ^ crc_tab[(crc ^ *block++) & 0xFF]; }
	return (crc ^ 0xFFFFFFFF);
}

void chksum_crc32gentab() {
	unsigned long crc, poly;
	int i, j;

	poly = 0xEDB88320L;
	for (i = 0; i < 256; i++) {
		crc = i;
		for (j = 8; j > 0; j--) {
			if (crc & 1) {
				crc = (crc >> 1) ^ poly;
			} else {
				crc >>= 1;
			}
		}
		crc_tab[i] = crc;
	}
}

void testCrc32() {
	chksum_crc32gentab();
	//pspDebugScreenPrintf("%08X\n", chksum_crc32((unsigned char *)"test", 4));
	emitInt(chksum_crc32(NULL, 0));
	int value = chksum_crc32((unsigned char *)"test", 4);
	assert(value == 0xD87F7E0C);
	assert(value == -662733300);
	emitInt(value);
}

void testIntegerSum() {
	int n, sum = 0;
	for (n = -50; n < 100; n++) sum += n;
	assert(sum == 3675);
	assert(n == 100);
	emitInt(sum);
	emitInt(n);
}

void testPrintf() {
	char buffer[32];
	int var = 240;
	sprintf(buffer, "%f"  , (float)var); emitString(buffer);
	sprintf(buffer, "%.2f", 240.0f); emitString(buffer);
	assert(strcmp(buffer, "240.00") == 0);
}

void testMalloc() {
	char *data = malloc(16);
	assert(data);
	strcpy(data, "This is a test");
	emitString(data);
	assert(data[0] == 'T');
	free(data);
}

int main(int argc, char* argv[]) {
	float f = 1.0;
	int n;
	//setupCallbacks();

	pspDebugScreenInit();

	testIntegerSum();
	testCrc32();
	testMalloc();
	emitFloat(0.1);
	emitFloat(f);

	for (n = 0; n < 2; n++) {
		sceDisplayWaitVblankStart();
		pspDebugScreenSetXY(0, 1);
		pspDebugScreenPrintf("Hola %f!", f);
		f += 0.1;
		emitInt(chksum_crc32((unsigned char *)0x04000000, 4 * 512 * 16));
	}

	//testPrintf();

	assert(0);

	return 0;
}