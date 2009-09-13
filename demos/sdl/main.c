#include <pspsdk.h>    
#include <pspkernel.h>
#include <psppower.h>
#include <pspctrl.h>
#include <pspdisplay.h>
#include <pspdebug.h>  

#include <SDL/SDL.h>

#define printf pspDebugScreenPrintf

PSP_MODULE_INFO("ModuleTest", 0, 1, 0); 
PSP_MAIN_THREAD_ATTR(PSP_THREAD_ATTR_USER);  

//#include "fire.c"

#define dbreak asm("dbreak;")

int main() {
	pspDebugScreenInit();
	printf("[0]");
	SDL_Init(0);
	printf("[1]");
	dbreak;
	SDL_InitSubSystem(SDL_INIT_VIDEO);
	printf("[2]");
	
	return 0;
}
