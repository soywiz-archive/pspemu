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
SET SOURCES=%SOURCES% pspemu/utils/Audio.d
SET SOURCES=%SOURCES% pspemu/utils/Utils.d
SET SOURCES=%SOURCES% pspemu/utils/VirtualFileSystem.d

SET SOURCES=%SOURCES% pspemu/models/IDisplay.d
SET SOURCES=%SOURCES% pspemu/models/IController.d
SET SOURCES=%SOURCES% pspemu/models/IDebugSource.d
SET SOURCES=%SOURCES% pspemu/models/ISyscall.d
REM SET SOURCES=%SOURCES% pspemu/models/IEmulatorState.d

SET SOURCES=%SOURCES% pspemu/formats/Pbp.d
SET SOURCES=%SOURCES% pspemu/formats/Psf.d
SET SOURCES=%SOURCES% pspemu/formats/Elf.d
SET SOURCES=%SOURCES% pspemu/formats/ElfDwarf.d

SET SOURCES=%SOURCES% pspemu/hle/Loader.d
SET SOURCES=%SOURCES% pspemu/hle/Module.d
SET SOURCES=%SOURCES% pspemu/hle/Syscall.d
SET SOURCES=%SOURCES% pspemu/hle/Types.d

SET SOURCES=%SOURCES% pspemu/hle/kd/audio.d
SET SOURCES=%SOURCES% pspemu/hle/kd/display.d
SET SOURCES=%SOURCES% pspemu/hle/kd/ge.d
SET SOURCES=%SOURCES% pspemu/hle/kd/ctrl.d
SET SOURCES=%SOURCES% pspemu/hle/kd/iofilemgr.d
SET SOURCES=%SOURCES% pspemu/hle/kd/modulemgr.d
SET SOURCES=%SOURCES% pspemu/hle/kd/stdio.d
SET SOURCES=%SOURCES% pspemu/hle/kd/sysmem.d
SET SOURCES=%SOURCES% pspemu/hle/kd/threadman.d
SET SOURCES=%SOURCES% pspemu/hle/kd/loadexec.d
SET SOURCES=%SOURCES% pspemu/hle/kd/utils.d
SET SOURCES=%SOURCES% pspemu/hle/kd/rtc.d
SET SOURCES=%SOURCES% pspemu/hle/kd/pspnet_inet.d
SET SOURCES=%SOURCES% pspemu/hle/kd/hpremote.d
SET SOURCES=%SOURCES% pspemu/hle/kd/loadcore.d
SET SOURCES=%SOURCES% pspemu/hle/kd/exceptionman.d

SET SOURCES=%SOURCES% pspemu/core/Memory.d

SET SOURCES=%SOURCES% pspemu/core/cpu/Cpu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Registers.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Instruction.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Interrupts.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Switch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Utils.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Table.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Assembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Disassembler.d
SET SOURCES=%SOURCES% pspemu/core/cpu/Test.d
SET SOURCES=%SOURCES% pspemu/core/cpu/InstructionCounter.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Alu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Branch.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Jump.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Memory.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Misc.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Fpu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/VFpu.d
SET SOURCES=%SOURCES% pspemu/core/cpu/ops/Unimplemented.d

SET SOURCES=%SOURCES% pspemu/core/gpu/Gpu.d
SET SOURCES=%SOURCES% pspemu/core/gpu/Commands.d
SET SOURCES=%SOURCES% pspemu/core/gpu/Types.d
SET SOURCES=%SOURCES% pspemu/core/gpu/DisplayList.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Special.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Flow.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Colors.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Draw.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Matrix.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Texture.d
SET SOURCES=%SOURCES% pspemu/core/gpu/ops/Enable.d
SET SOURCES=%SOURCES% pspemu/core/gpu/impl/GpuOpengl.d
SET SOURCES=%SOURCES% pspemu/core/gpu/impl/GpuSoftware.d

SET SOURCES=%SOURCES% gdi32.lib

REM SET RELEASE=-noboundscheck -inline -O -release
SET RELEASE=-noboundscheck -O -release -Jresources
REM SET RELEASE=-O

SET EXTRA=-quiet -deps=deps.lst

SET UNITTEST=-unittest -version=Unittest -d
REM SET UNITTEST=

REM -cov to code coverage, then show the last line of .lst files.
REM -cov seems to fail with -unittest
