@echo off
del pspemu.exe 2> NUL
SET PATH="%~dp0\dev\dmd2\windows\bin";%PATH%
SET FLAGS=
SET FLAGS=%FLAGS% -d -Jimport -O -release -noboundscheck
REM SET FLAGS=%FLAGS% -gc

SET LIBS=
SET LIBS=%LIBS% dfl/olepro32_dfl.lib
SET LIBS=%LIBS% dfl/shell32_dfl.lib
SET LIBS=%LIBS% dfl/user32_dfl.lib
SET LIBS=%LIBS% gdi32.lib
SET LIBS=%LIBS% comctl32.lib
SET LIBS=%LIBS% advapi32.lib
SET LIBS=%LIBS% comdlg32.lib
SET LIBS=%LIBS% ole32.lib
SET LIBS=%LIBS% uuid.lib
SET LIBS=%LIBS% ws2_32.lib

xfbuild.exe %* -Isrc src\pspemu\main.d +xstd +xcore %FLAGS% +o=pspemu.exe %LIBS% import\psp.res
del *.rsp 2> NUL