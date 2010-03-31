@ECHO OFF
CLS

SET EXE=mips_asm.exe

dev\php\php.exe dev\build.php assembler %EXE%

IF EXIST "%EXE%" (
	%EXE% %*
)