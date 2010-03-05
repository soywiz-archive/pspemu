@echo off

REM SET DMD=dmd\windows\bin\dfl.exe
SET DMD=dmd\windows\bin\dmd.exe

IF NOT EXIST "%DMD%" (
	PUSHD dmd
	CALL setup.bat
	POPD
)

SET SOURCES=

SET SOURCES=%SOURCES% pspemu/utils/SparseMemory.d
SET SOURCES=%SOURCES% pspemu/utils/Expression.d
SET SOURCES=%SOURCES% pspemu/utils/Assertion.d
SET SOURCES=%SOURCES% pspemu/utils/OpenGL.d

SET SOURCES=%SOURCES% pspemu/models/IDisplay.d

SET SOURCES=%SOURCES% pspemu/formats/Pbp.d
SET SOURCES=%SOURCES% pspemu/formats/Psf.d
SET SOURCES=%SOURCES% pspemu/formats/Elf.d

SET SOURCES=%SOURCES% pspemu/core/Memory.d

SET SOURCES=%SOURCES% pspemu/core/cpu/Registers.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Instruction.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Switch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Utils.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Table.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Assembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Disassembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Cpu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Test.d

SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Alu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Branch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Jump.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Memory.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Misc.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Fpu.d

SET RELEASE=-noboundscheck -inline -O -release

SET EXTRA=-quiet -deps=deps.lst

SET UNITTEST=-unittest -version=Unittest
REM SET UNITTEST=

REM -cov to code coverage, then show the last line of .lst files.
REM -cov seems to fail with -unittest
