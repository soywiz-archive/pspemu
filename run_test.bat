@echo off

CALL _sources.bat

del /q test.exe 2> NUL
%DMD% %SOURCES% %UNITTEST% -g pspemu/exe/test.d -oftest
del /q test.map 2> NUL
del /q test.obj 2> NUL
if EXIST "test.exe" (
	REM ddbg -cmd "r;us;q" test.exe %*
	test.exe %*
)