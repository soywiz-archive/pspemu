@ECHO OFF
REM http://minpspw.sourceforge.net/
SET PSPSDK=%CD%/../dmd/pspsdk
SET LIBS=-lpspgum -lpspgu -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspctrl -lpspsdk -lc -lpspnet -lpspnet_inet -lpspnet_apctl -lpspnet_resolver -lpsputility -lpspuser -lpspkernel
SET SOURCES=
SET SOURCES=%SOURCES% test1.c
REM SET FLAGS=-G0 -Wall -O2 -g -gstabs
SET FLAGS=-Wall -g
c:\pspsdk\bin\psp-gcc -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 %FLAGS% %SOURCES% %LIBS% -o test1.elf
c:\pspsdk\bin\psp-fixup-imports test1.elf
IF EXIST STRIP_ELF (
	c:\pspsdk\bin\psp-strip test1.elf
)