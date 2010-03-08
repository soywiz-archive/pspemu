@ECHO OFF
REM http://minpspw.sourceforge.net/
SET PSPSDK=%CD%/../dmd/pspsdk
SET LIBS=-lpspgum -lpspgu -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspctrl -lpspsdk -lc -lpspnet -lpspnet_inet -lpspnet_apctl -lpspnet_resolver -lpsputility -lpspuser -lpspkernel
REM SET FLAGS=-G0 -Wall -O2 -g -gstabs
SET FLAGS=-Wall -g

CALL :BUILD test1
CALL :BUILD test2

EXIT /B

:BUILD
	c:\pspsdk\bin\psp-gcc -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 %FLAGS% %1.c %LIBS% -o %1.elf
	c:\pspsdk\bin\psp-fixup-imports %1.elf
	IF EXIST STRIP_ELF (
		c:\pspsdk\bin\psp-strip %1.elf
	)
EXIT /B