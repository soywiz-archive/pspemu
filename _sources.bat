@echo off

SET DMD=dmd\windows\bin\dmd.exe

IF NOT EXIST "%DMD%" (
	PUSHD dmd
	CALL setup.bat
	POPD
)

SET SOURCES=
SET SOURCES=%SOURCES% pspemu/utils/sparse_memory.d
SET SOURCES=%SOURCES% pspemu/utils/expression.d
SET SOURCES=%SOURCES% pspemu/utils/assertion.d
SET SOURCES=%SOURCES% pspemu/formats/pbp.d
SET SOURCES=%SOURCES% pspemu/formats/psf.d
SET SOURCES=%SOURCES% pspemu/formats/elf.d
SET SOURCES=%SOURCES% pspemu/core/memory.d
SET SOURCES=%SOURCES% pspemu/core/cpu/registers.d
SET SOURCES=%SOURCES% pspemu/core/cpu/instruction.d
SET SOURCES=%SOURCES% pspemu/core/cpu/cpu_switch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/utils.d

SET SOURCES=%SOURCES% pspemu/core/cpu/ops/alu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/branch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/jump.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/memory.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/misc.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/fpu.d

SET SOURCES=%SOURCES% pspemu/core/cpu/table.d
SET SOURCES=%SOURCES% pspemu/core/cpu/assembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/disassembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/cpu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/test.d

SET RELEASE=-noboundscheck -inline -O -release

SET EXTRA=-quiet -deps=deps.lst

SET UNITTEST=-unittest -version=Unittest
REM SET UNITTEST=

REM -cov to code coverage, then show the last line of .lst files.
REM -cov seems to fail with -unittest
