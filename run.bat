@ECHO OFF

dev\php\php.exe dev\build.php

IF EXIST "pspemu.exe" (
	dev\dmd2\windows\bin\ddbg.exe -cmd "r;us;q" pspemu.exe %*
)