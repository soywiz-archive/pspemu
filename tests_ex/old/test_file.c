#include <pspkernel.h>
#include <stdio.h>
#include <stdarg.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>

PSP_MODULE_INFO("TEST_FILE", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

long long int test() {
	return -5;
}

int main() {
	FILE *f = NULL;
	
	printf("%lld", test());
	
	f = fopen("test_file.c.txt", "wb");
	if (f != NULL) {
		fprintf(f, "test:%f", 240.0f);
		fclose(f);
	}
	
	fclose(fopen("ms0:/tmp.bin", "wb"));
	
	return 0;
}