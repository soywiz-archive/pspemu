@echo off

SET DMD=dmd\windows\bin\dmd.exe

IF NOT EXIST "%DMD%" (
	PUSHD dmd
	CALL setup.bat
	POPD
)

SET SOURCES=
SET SOURCES=%SOURCES% src/utils/sparse_memory.d
SET SOURCES=%SOURCES% src/utils/expression.d
SET SOURCES=%SOURCES% src/utils/assertion.d
SET SOURCES=%SOURCES% src/formats/pbp.d
SET SOURCES=%SOURCES% src/formats/psf.d
SET SOURCES=%SOURCES% src/formats/elf.d
SET SOURCES=%SOURCES% src/core/memory.d
SET SOURCES=%SOURCES% src/core/cpu/registers.d
SET SOURCES=%SOURCES% src/core/cpu/instruction.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_switch.d
SET SOURCES=%SOURCES% src/core/cpu/utils.d

SET SOURCES=%SOURCES% src/core/cpu/ops/alu.d
SET SOURCES=%SOURCES% src/core/cpu/ops/branch.d
SET SOURCES=%SOURCES% src/core/cpu/ops/jump.d
SET SOURCES=%SOURCES% src/core/cpu/ops/memory.d
SET SOURCES=%SOURCES% src/core/cpu/ops/misc.d
SET SOURCES=%SOURCES% src/core/cpu/ops/fpu.d

SET SOURCES=%SOURCES% src/core/cpu/table.d
SET SOURCES=%SOURCES% src/core/cpu/assembler.d
SET SOURCES=%SOURCES% src/core/cpu/disassembler.d
SET SOURCES=%SOURCES% src/core/cpu/cpu.d
SET SOURCES=%SOURCES% src/core/cpu/test.d

SET RELEASE=-noboundscheck -inline -O -release

SET EXTRA=-quiet -deps=deps.lst

SET UNITTEST=-unittest -version=Unittest
REM SET UNITTEST=

REM -cov to code coverage, then show the last line of .lst files.
REM -cov seems to fail with -unittest
