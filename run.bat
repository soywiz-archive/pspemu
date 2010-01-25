@echo off

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
SET SOURCES=%SOURCES% src/core/cpu/cpu_utils.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_alu.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_branch.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_jump.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_memory.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_misc.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_ops_fpu.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_table.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_asm.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_disasm.d
SET SOURCES=%SOURCES% src/core/cpu/cpu.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_test.d

REM SET RELEASE=-noboundscheck -inline -O -release
SET RELEASE=

REM -cov to code coverage, then show the last line of .lst files.
REM -cov seems to fail with -unittest
dmd %SOURCES% -quiet -deps=deps.lst %RELEASE% -unittest -run src/exe/test.d %*