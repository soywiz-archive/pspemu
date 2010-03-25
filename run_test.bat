@ECHO OFF
CLS

SET PSPEMU_EXE=pspemu_test.exe

dev\php\php.exe dev\build.php test %PSPEMU_EXE%

IF EXIST "%PSPEMU_EXE%" (
	%PSPEMU_EXE% %*
)