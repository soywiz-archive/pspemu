@echo off
del /Q .deps.all .deps *.rsp .objs\* .objs.all\* 2> NUL
del *.obj ..\src\*.obj /s /Q 2> NUL