@ECHO OFF
REM http://www.digitalmars.com/d/2.0/changelog.html
SET PATH="%CD%\bin";%PATH%

REM SET DMD_HTTP=http://ftp.digitalmars.com/dmd.2.040.zip
SET DMD_HTTP=http://pspemu.googlecode.com/files/dmd.2.040.zip
SET DMD_ZIP=dmd.2.040.zip

REM SET DFL_HTTP=http://www.dprogramming.com/dfl/snapshots/dfl-20090411.zip
SET DFL_HTTP=http://pspemu.googlecode.com/files/dfl_dmd2040.7z
SET DFL_ZIP=dfl_dmd2040.7z

SET DSSS_HTTP=http://svn.dsource.org/projects/dsss/downloads/0.78/dsss-0.78-x86-windows.zip

ECHO Preparing DMD...
IF NOT EXIST "windows\bin\dmd.exe" (
	IF NOT EXIST "%DMD_ZIP%" (
		ECHO Downloading %DMD_HTTP%...
		..\utils\httpget %DMD_HTTP% %DMD_ZIP%
	)
	..\utils\7z -bd -y x %DMD_ZIP%
	MOVE dmd2\html > NUL 2> NUL
	MOVE dmd2\samples > NUL 2> NUL
	MOVE dmd2\src > NUL 2> NUL
	MOVE dmd2\windows > NUL 2> NUL
	MOVE dmd2\license.txt > NUL 2> NUL
	MOVE dmd2\README.TXT > NUL 2> NUL
	RD /Q /S dmd2 > NUL 2> NUL
	IF NOT EXIST "windows\bin\dmd.exe" (
		ECHO Error installing DMD
		EXIT /B
	)
)

ECHO Preparing DFL...
IF NOT EXIST "windows\bin\dfl.exe" (
	IF NOT EXIST "%DFL_ZIP%" (
		ECHO Downloading %DFL_HTTP%...
		..\utils\httpget %DFL_HTTP% %DFL_ZIP%
	)
	..\utils\7z -bd -y x %DFL_ZIP%
	windows\bin\dfl -dfl-build
	IF NOT EXIST "windows\bin\dfl.exe" (
		ECHO Error installing DFL
		EXIT /B
	)
)

REM bin\dsss net install dwt-win