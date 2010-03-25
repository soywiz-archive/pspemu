@ECHO OFF
CLS

SET PSPEMU_EXE=pspemu_normal.exe

dev\php\php.exe dev\build.php normal %PSPEMU_EXE%

IF EXIST "%PSPEMU_EXE%" (
	%PSPEMU_EXE% %*
)