@echo off

CALL _sources.bat

del /q pspemu.exe 2> NUL
%DMD% %SOURCES% %UNITTEST% -g src/exe/test.d -ofpspemu
del /q pspemu.map 2> NUL
del /q pspemu.obj 2> NUL
if EXIST "pspemu.exe" (
	REM ddbg -cmd "r;us;q" pspemu.exe %*
	pspemu.exe %*
)