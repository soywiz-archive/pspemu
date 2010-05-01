TARGET = intraFontTest
OBJS = fonttest.o graphics.o framebuffer.o ../../libccc.o ../../intraFont.o

INCDIR =
CFLAGS = -O2 -G0 -Wall -g
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASFLAGS = $(CFLAGS)

LIBDIR =
LDFLAGS = 
LIBS = -lpspgum -lpspgu -lpng -lz -lm

EXTRA_TARGETS = EBOOT.PBP
PSP_EBOOT_TITLE = intraFont Test

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak

