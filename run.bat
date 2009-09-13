@echo off
call build.bat

IF NOT EXIST pspemu.exe GOTO end
pspemu.exe %*

:end