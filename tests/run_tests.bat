@echo off
SET TESTS_EXE="%~dp0\pspemu_tests.exe"
DEL pspemu_tests.exe 2> NUL
"%~dp0\..\dev\dmd2\windows\bin\xfbuild" "%~dp0\tests\main.d" -I"%~dp0\." -I"%~dp0\..\src" -J"%~dp0\..\import" -J"%~dp0\..\import\tests" +xstd +xcore +o=%TESTS_EXE% %* 
IF EXIST %TESTS_EXE% (
	DEL *.rsp 2> NUL
	%TESTS_EXE%
	DEL %TESTS_EXE%
)