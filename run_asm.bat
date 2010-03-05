@echo off

CALL _sources.bat

del /q mipsasm.exe 2> NUL
%DMD% %SOURCES% pspemu/exe/assembler.d -ofmipsasm
del /q mipsasm.map 2> NUL
del /q mipsasm.obj 2> NUL
if EXIST "mipsasm.exe" (
	REM ddbg mipsasm.exe %*
	mipsasm.exe %*
)