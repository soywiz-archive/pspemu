@echo off

CALL _sources.bat

del /q pspemu.exe 2> NUL
dmd %SOURCES% %UNITTEST% -gc src/exe/test.d -ofpspemu
del /q pspemu.map 2> NUL
del /q pspemu.obj 2> NUL
if EXIST "pspemu.exe" (
	REM ddbg pspemu.exe %*
	pspemu.exe %*
)