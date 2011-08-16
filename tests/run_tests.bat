@echo off
CALL "%~dp0\..\dev\prepare.bat"
SET TESTS_EXE="%~dp0\pspemu_tests.exe"
DEL pspemu_tests.exe 2> NUL
IF "%1"=="-version=ALL_TESTS" (
	SET TESTS_EXE="%~dp0\pspemu_tests_all.exe"
)
"%~dp0\..\dev\dmd2\windows\bin\xfbuild" "%~dp0\tests\main.d" -I"%~dp0\." -I"%~dp0\..\src" -J"%~dp0\..\import" -J"%~dp0\..\import\tests" +xstd +xcore +o=%TESTS_EXE% -g -debug %* 
IF EXIST %TESTS_EXE% (
	DEL *.rsp 2> NUL
	REM "%~dp0\..\ddbg.exe" -cmd "r;us;q" %TESTS_EXE%
	%TESTS_EXE%
	REM DEL %TESTS_EXE%
)