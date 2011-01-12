TARGET = OrthoInD
OBJS = 
OBJS += module.o ortho.o 
OBJS += ../../pspsdk/pspctrl.d

CFLAGS = -O2 -Wall -I"../.."
DFLAGS = $(CFLAGS)
CXXFLAGS = $(CFLAGS)
ASFLAGS = $(CFLAGS)

LIBDIR = ..
LIBS = -lgphobos -lpspgum -lpspgu -lm
LDFLAGS =

EXTRA_TARGETS = EBOOT.PBP
PSP_EBOOT_TITLE = Ortho In D

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak 
