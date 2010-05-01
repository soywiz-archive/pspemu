@echo off
set PSPSDK=%CD%\..\..\dev\pspsdk

IF NOT EXIST "SQUIRREL3\lib\squirrel.a" (
	echo Building squirrel...
	PUSHD SQUIRREL3\squirrel
		"%PSPSDK%/bin/psp-gcc" -O2 -c *.cpp -I..\include
		"%PSPSDK%/bin/psp-ar" rcs squirrel.a *.o
		MOVE /Y squirrel.a ..\lib
		DEL /Q *.o > NUL 2> NUL
	POPD
)
	
IF NOT EXIST "SQUIRREL3\lib\sqstdlib.a" (
	echo Building sqstdlib...
	PUSHD SQUIRREL3\sqstdlib
		"%PSPSDK%/bin/psp-gcc" -O2 -c *.cpp -I..\include
		"%PSPSDK%/bin/psp-ar" rcs sqstdlib.a *.o
		MOVE /Y sqstdlib.a ..\lib
		DEL /Q *.o > NUL 2> NUL
	POPD
)

DEL /Q EBOOT.PBP > NUL 2> NUL
DEL /Q squirrel.elf > NUL 2> NUL
SET SOURCES=
SET SOURCES=%SOURCES% main.cpp
SET SOURCES=%SOURCES% intraFont/intraFont.c
SET SOURCES=%SOURCES% intraFont/libccc.c
"%PSPSDK%/bin/psp-gcc" -I. -ISQUIRREL3\include -I"%PSPSDK%/psp/sdk/include" -I"%PSPSDK%/psp/sdk/include/SDL" -Dmain=SDL_main -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g %SOURCES% SQUIRREL3\lib\squirrel.a SQUIRREL3\lib\sqstdlib.a -lSDL_image -lpng -ljpeg -lz -lsqlite3 -lSDLmain -lSDL -lm -lGL -lpspvfpu -LC:/pspsdk/psp/sdk/lib -lpspdebug -lpspgum -lpspgu -lpspctrl -lpspge -lpspdisplay -lpsphprm -lpspsdk -lpsprtc -lpspaudio -lstdc++ -lc -lpspuser -lpsputility -lpspkernel -lpspnet_inet -o squirrel.elf
"%PSPSDK%/bin/psp-fixup-imports" squirrel.elf
COPY /Y squirrel.elf squirrel_strip.elf > NUL 2> NUL
"%PSPSDK%/bin/psp-strip" squirrel_strip.elf
"%PSPSDK%/bin/mksfo" "Squirrel-PSP" param.sfo
"%PSPSDK%/bin/pack-pbp" EBOOT.PBP param.sfo NULL NULL NULL NULL NULL squirrel_strip.elf NULL > NUL
DEL /Q squirrel_strip.elf