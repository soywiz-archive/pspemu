@echo off
del pspemu.exe 2> NUL
SET PATH="%~dp0\dev\dmd2\windows\bin";%PATH%
xfbuild.exe %* pspemu\main.d +xstd +xcore -d -Jimport -gc -O -release -noboundscheck +o=pspemu.exe dfl/olepro32_dfl.lib dfl/shell32_dfl.lib dfl/user32_dfl.lib gdi32.lib comctl32.lib advapi32.lib comdlg32.lib ole32.lib uuid.lib ws2_32.lib import\psp.res
del *.rsp 2> NUL