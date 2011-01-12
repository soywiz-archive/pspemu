TARGET = controller_basic
OBJS = 
OBJS += module.o main.o 
OBJS += ../../../pspsdk/pspctrl.d
OBJS += ../../../pspsdk/utils/callback.d
OBJS += ../../../pspsdk/utils/vram.d

CFLAGS = -O2 -Wall -I"../../.."
DFLAGS = $(CFLAGS)
CXXFLAGS = $(CFLAGS)
ASFLAGS = $(CFLAGS)

LIBDIR = ..
LIBS = -lgphobos -lpspgum -lpspgu -lm
LDFLAGS =

EXTRA_TARGETS = EBOOT.PBP
PSP_EBOOT_TITLE = Basic controller sample

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak 
