@ECHO OFF
CLS

DEL /Q gui_test.exe > NUL 2> NUL
dev\dmd2\windows\bin\dfl pspemu\gui\HexEditor.d sandbox\gui_test.d -ofgui_test.exe
IF EXIST "gui_test.exe" (
	gui_test.exe
)