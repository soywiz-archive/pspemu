@echo off
set PSPSDK=%CD%\..\..\dev\pspsdk
REM set PATH="%PSPSDK%\bin";%PATH%
REM ..\..\dev\php\php -r"file_put_contents('squirrel_3.0_beta1.tar.gz', file_get_contents('http://downloads.sourceforge.net/project/squirrel/squirrel3/squirrel%203.0%20beta%201/squirrel_3.0_beta1.tar.gz?use_mirror=ovh'));"

IF NOT EXIST "SQUIRREL3" (
	ECHO Must download and extract squirrel3 on extra/squirrel/SQUIRREL3
	ECHO http://sourceforge.net/projects/squirrel/
	EXIT /B
)

IF NOT EXIST "SQUIRREL3\squirrel\squirrel.a" (
	echo Building squirrel...
	PUSHD SQUIRREL3\squirrel
		"%PSPSDK%/psp-gcc" -O2 -c *.cpp -I..\include
		"%PSPSDK%/psp-ar" rcs squirrel.a *.o
		REM MOVE /Y squirrel.a ..\..
	POPD
)
	
IF NOT EXIST "SQUIRREL3\sqstdlib\sqstdlib.a" (
	echo Building sqstdlib...
	PUSHD SQUIRREL3\sqstdlib
		"%PSPSDK%/psp-gcc" -O2 -c *.cpp -I..\include
		"%PSPSDK%/psp-ar" rcs sqstdlib.a *.o
		REM MOVE /Y sqstdlib.a ..\..
	POPD
)

del /q EBOOT.PBP > NUL 2> NUL
del /q squirrel.elf > NUL 2> NUL
"%PSPSDK%/bin/psp-gcc" -I. -ISQUIRREL3\include -I"%PSPSDK%/psp/sdk/include" -I"%PSPSDK%/psp/sdk/include/SDL" -Dmain=SDL_main -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g main.cpp SQUIRREL3\squirrel\squirrel.a SQUIRREL3\sqstdlib\sqstdlib.a -lSDL_image -lpng -ljpeg -lz -lsqlite3 -lSDLmain -lSDL -lm -lGL -lpspvfpu -LC:/pspsdk/psp/sdk/lib -lpspdebug -lpspgum -lpspgu -lpspctrl -lpspge -lpspdisplay -lpsphprm -lpspsdk -lpsprtc -lpspaudio -lstdc++ -lc -lpspuser -lpsputility -lpspkernel -lpspnet_inet -o squirrel.elf
"%PSPSDK%/bin/psp-fixup-imports" squirrel.elf
"%PSPSDK%/bin/psp-strip" squirrel.elf
"%PSPSDK%/bin/mksfo" "Squirrel-PSP" param.sfo
"%PSPSDK%/bin/pack-pbp" EBOOT.PBP param.sfo NULL NULL NULL NULL NULL squirrel.elf NULL > NUL