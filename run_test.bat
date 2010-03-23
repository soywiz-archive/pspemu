@ECHO OFF

PUSHD tests
	CALL make.bat
POPD

CALL _sources.bat

DEL /Q test.exe 2> NUL
%DMD% %SOURCES% %UNITTEST% -O -release -g pspemu/exe/test.d -oftest
DEL /Q test.map 2> NUL
DEL /Q test.obj 2> NUL
IF EXIST "test.exe" (
	REM ddbg -cmd "r;us;q" test.exe %*
	test.exe %*
)