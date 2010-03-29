#include <pspkernel.h>
#include <stdio.h>
#include <stdarg.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>

PSP_MODULE_INFO("TEST_MALLOC", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

int main() {
	void *ptr1 = malloc(1024);
	void *ptr2 = malloc(1024);
	free(ptr2);
	free(ptr1);
	
	return 0;
}