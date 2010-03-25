@ECHO OFF
CLS

REM DEL /Q pspemu.exe 2> NUL > NUL
dev\php\php.exe dev\build.php debug pspemu_debug.exe

IF EXIST "pspemu.exe" (
	dev\dmd2\windows\bin\ddbg.exe -cmd "r;us;q" pspemu_debug.exe %*
)