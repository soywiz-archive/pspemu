@echo off
IF NOT EXIST "%~dp0\libs\wx_libs.7z" (
	PUSHD "%~dp0\libs"
	"%~dp0\bin\wget.exe" http://pspemu.googlecode.com/files/wx_libs.7z
	POPD
)

IF NOT EXIST "%~dp0\libs\wx" (
	PUSHD "%~dp0\libs"
	"%~dp0\bin\7za.exe" x wx_libs.7z
	POPD
)