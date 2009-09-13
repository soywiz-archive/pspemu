TARGET = minifire
OBJS = main.o 

INCDIR =
CFLAGS = -G0 -Wall -O0 -ggdb 

ifeq ($(BUILD_V1),1)
CFLAGS += -DBUILD_V1
endif
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASFLAGS = $(CFLAGS)

LIBDIR =
LDFLAGS = -nostartfiles
LIBS= 

EXTRA_TARGETS = EBOOT.PBP
PSP_EBOOT_TITLE = Mini Fire

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak

FIXUP=true
