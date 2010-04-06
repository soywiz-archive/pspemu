@ECHO OFF
CLS

DEL /Q gui_test.exe > NUL 2> NUL
dev\dmd2\windows\bin\dfl pspemu\utils\Utils.d pspemu\core\Memory.d pspemu\core\cpu\Registers.d pspemu\gui\Utils.d pspemu\gui\HexEditor.d sandbox\gui_test.d -debug -ofgui_test.exe
DEL /Q gui_test.map > NUL 2> NUL
DEL /Q gui_test.obj > NUL 2> NUL
IF EXIST "gui_test.exe" (
	gui_test.exe
)