@echo off
set PSPSDK=%CD%\..\..\dev\pspsdk
set PATH="%PSPSDK%\bin";%PATH%
REM ..\..\dev\php\php -r"file_put_contents('squirrel_3.0_beta1.tar.gz', file_get_contents('http://downloads.sourceforge.net/project/squirrel/squirrel3/squirrel%203.0%20beta%201/squirrel_3.0_beta1.tar.gz?use_mirror=ovh'));"

IF NOT EXIST "SQUIRREL3" (
	ECHO Must download and extract squirrel3 on extra/squirrel/SQUIRREL3
	ECHO http://sourceforge.net/projects/squirrel/
	EXIT /B
)

IF NOT EXIST "SQUIRREL3\squirrel\squirrel.a" (
	echo Building squirrel...
	PUSHD SQUIRREL3\squirrel
		psp-gcc -O2 -c *.cpp -I..\include
		psp-ar rcs squirrel.a *.o
		REM MOVE /Y squirrel.a ..\..
	POPD
)
	
IF NOT EXIST "SQUIRREL3\sqstdlib\sqstdlib.a" (
	echo Building sqstdlib...
	PUSHD SQUIRREL3\sqstdlib
		psp-gcc -O2 -c *.cpp -I..\include
		psp-ar rcs sqstdlib.a *.o
		REM MOVE /Y sqstdlib.a ..\..
	POPD
)

"%PSPSDK%/bin/psp-gcc" -ISQUIRREL3\include -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g main.cpp SQUIRREL3\squirrel\squirrel.a SQUIRREL3\sqstdlib\sqstdlib.a -lpspdebug -lstdc++ -lc -lm -lpspdisplay -lpspsdk -lpspuser -lpspkernel -lpspgu -lpspge -o squirrel.elf
"%PSPSDK%/bin/psp-fixup-imports" squirrel.elf
"%PSPSDK%/bin/psp-strip" squirrel.elf
"%PSPSDK%/bin/mksfo" "Squirrel-PSP" param.sfo
"%PSPSDK%/bin/pack-pbp" EBOOT.PBP param.sfo NULL NULL NULL NULL NULL squirrel.elf NULL