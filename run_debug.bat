@ECHO OFF
CLS

SET PSPEMU_EXE=pspemu_debug.exe

dev\php\php.exe dev\build.php debug %PSPEMU_EXE%

IF EXIST "%PSPEMU_EXE%" (
	dev\dmd2\windows\bin\ddbg -cmd "r;us;q" %PSPEMU_EXE% %*
)