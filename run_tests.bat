@echo off
del pspemu_tests.exe 2> NUL
dev\dmd2\windows\bin\rebuild tests\tests\main -Itests -Isrc -ofpspemu_tests.exe -oq.objs
IF EXIST pspemu_tests.exe (
	pspemu_tests.exe
	del pspemu_tests.exe
)