@echo off

IF "%DEV_DMD_IN_PATH%"=="1" GOTO DEV_DMD_ALREADY_IN_PATH
SET DEV_DMD_IN_PATH=1
SET PATH=%~dp0\..\windows\bin;%PATH%

:DEV_DMD_ALREADY_IN_PATH

:MAKE_DMD
pushd dmd
make -fwin32.mak release
popd
copy dmd\*.exe ..\windows\bin /Y

:MAKE_DRUNTIME
pushd druntime
make -f win32.mak
popd

:MAKE_PHOBOS
pushd phobos
make -f win32.mak
popd
copy phobos\phobos.lib ..\windows\lib\phobos.lib