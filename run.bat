@echo off

CALL _sources.bat
SET DMD=dmd\windows\bin\dfl.exe
SET SOURCES=%SOURCES% pspemu/gui/MainForm.d
SET SOURCES=%SOURCES% pspemu/gui/GLControl.d
SET SOURCES=%SOURCES% pspemu/gui/DisplayForm.d

del /q pspemu.exe 2> NUL
%DMD% %SOURCES% %RELEASE% -g pspemu/exe/pspemu.d -ofpspemu
del /q pspemu.map 2> NUL
del /q pspemu.obj 2> NUL
if EXIST "pspemu.exe" (
	REM ddbg -cmd "r;us;q" pspemu.exe %*
	pspemu.exe %*
)