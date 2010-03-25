@ECHO OFF
CLS

REM DEL /Q pspemu.exe 2> NUL > NUL
dev\php\php.exe dev\build.php release pspemu.exe

IF EXIST "pspemu.exe" (
	pspemu.exe %*
)