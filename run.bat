@echo off

SET SOURCES=
SET SOURCES=%SOURCES% src/formats/pbp.d
SET SOURCES=%SOURCES% src/formats/psf.d
SET SOURCES=%SOURCES% src/core/memory.d
SET SOURCES=%SOURCES% src/core/cpu/registers.d
SET SOURCES=%SOURCES% src/core/cpu/instruction.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_switch.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_alu.d
SET SOURCES=%SOURCES% src/core/cpu/cpu_table.d
SET SOURCES=%SOURCES% src/core/cpu/cpu.d

dmd %SOURCES% -unittest -run src/main.d