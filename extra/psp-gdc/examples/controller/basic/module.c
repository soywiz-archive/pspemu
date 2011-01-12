#include <pspkernel.h>
#include <pspdebug.h> 
#include <pspsuspend.h>

/* Define the module info section */
PSP_MODULE_INFO("CONTROLTEST", 0, 1, 1);

/* Define the main thread's attribute value (optional) */
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | THREAD_ATTR_VFPU);
