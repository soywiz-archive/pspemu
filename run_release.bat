@ECHO OFF
CLS

SET PSPEMU_EXE=pspemu.exe

dev\php\php.exe dev\build.php release %PSPEMU_EXE%

IF EXIST "%PSPEMU_EXE%" (
	dev\upx\upx.exe %PSPEMU_EXE%
	%PSPEMU_EXE% %*
)