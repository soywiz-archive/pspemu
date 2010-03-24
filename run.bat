@echo off

REM SET DEBUG=0
SET DEBUG=1

CALL _sources.bat
SET DMD=dmd\windows\bin\dfl.exe
SET SOURCES=%SOURCES% pspemu/gui/MainForm.d
SET SOURCES=%SOURCES% pspemu/gui/GLControl.d
SET SOURCES=%SOURCES% pspemu/gui/DisplayForm.d

del /q pspemu.exe 2> NUL
%DMD% %SOURCES% %RELEASE% -version=DEBUG_LOADER -g pspemu/exe/pspemu.d -ofpspemu
del /q pspemu.map 2> NUL
del /q pspemu.obj 2> NUL
IF EXIST "pspemu.exe" (
	IF %DEBUG% == 1 (
		dmd\windows\bin\ddbg -cmd "r;us;q" pspemu.exe %*
	) ELSE (
		pspemu.exe %*
	)
)