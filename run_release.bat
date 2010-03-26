@ECHO OFF
CLS

SET PSPEMU_EXE=pspemu.exe

ECHO Disabled ATM. Please execute run.bat instead.
PAUSE
EXIT /B

dev\php\php.exe dev\build.php release %PSPEMU_EXE%

IF EXIST "%PSPEMU_EXE%" (
	REM dev\upx\upx.exe %PSPEMU_EXE%
	%PSPEMU_EXE% %*
)