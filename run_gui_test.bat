@ECHO OFF
CLS

SET SOURCES=
SET SOURCES=%SOURCES% sandbox\gui_test.d 
SET SOURCES=%SOURCES% pspemu\utils\Utils.d
SET SOURCES=%SOURCES% pspemu\core\Memory.d
SET SOURCES=%SOURCES% pspemu\core\cpu\Registers.d
SET SOURCES=%SOURCES% pspemu\gui\Utils.d
SET SOURCES=%SOURCES% pspemu\gui\HexEditor.d
SET SOURCES=%SOURCES% pspemu\gui\HexEditorUtils.d
SET SOURCES=%SOURCES% pspemu\gui\HexEditorForm.d
SET SOURCES=%SOURCES% pspemu\gui\Registers.d

DEL /Q gui_test.exe > NUL 2> NUL
dev\dmd2\windows\bin\dfl %SOURCES% -debug -ofgui_test.exe
DEL /Q gui_test.map > NUL 2> NUL
DEL /Q gui_test.obj > NUL 2> NUL
IF EXIST "gui_test.exe" (
	gui_test.exe
)