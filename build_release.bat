@echo off
REM copy build.rf build2.rf
del bin\pspemu31.exe
set EXTRA=
REM set EXTRA=%EXTRA% -vtls
set EXTRA=%EXTRA% 
set EXTRA=%EXTRA% -c -od"obj" -op
set EXTRA=%EXTRA% -deps=deps.txt

CALL update_svn_info.bat

c:\dev\dmd2\windows\bin\dmd %EXTRA% @build.rf %*