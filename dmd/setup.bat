@ECHO OFF
SET PATH="%CD%\bin";%PATH%

REM SET DSSS_HTTP=http://svn.dsource.org/projects/dsss/downloads/0.78/dsss-0.78-x86-windows.zip

REM ---------------------------------------------------------------------------
REM http://www.digitalmars.com/d/2.0/changelog.html
SET NAME=DMD
SET TEXT=Preparing DMD...
SET CHECK=windows\bin\dmd.exe
SET ZIP=dmd.2.040.zip
SET HTTP=http://pspemu.googlecode.com/files/dmd.2.040.zip
SET POST=CALL POST_DMD
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------

SET NAME=DFL
SET TEXT=Preparing DFL...
SET CHECK=windows\bin\dfl.exe
SET ZIP=dfl_dmd2040.7z
REM SET HTTP=http://www.dprogramming.com/dfl/snapshots/dfl-20090411.zip
SET HTTP=http://pspemu.googlecode.com/files/dfl_dmd2040.7z
SET POST=CALL POST_DFL
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------

SET NAME=SDK
SET TEXT=Preparing PSPSDK...
SET CHECK=pspsdk\bin\psp-gcc.exe
SET ZIP=pspsdk.7z
SET HTTP=http://pspemu.googlecode.com/files/pspsdk.7z
SET POST=CALL POST_SDK
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------

EXIT /B

:POST_DMD
	MOVE dmd2\html > NUL 2> NUL
	MOVE dmd2\samples > NUL 2> NUL
	MOVE dmd2\src > NUL 2> NUL
	MOVE dmd2\windows > NUL 2> NUL
	MOVE dmd2\license.txt > NUL 2> NUL
	MOVE dmd2\README.TXT > NUL 2> NUL
	RD /Q /S dmd2 > NUL 2> NUL
EXIT /B

:POST_DFL
	windows\bin\dfl -dfl-build
EXIT /B

:POST_SDK
EXIT /B

:INSTALL_PAK
	REM SET TEXT=%1
	REM SET CHECK=%2
	REM SET ZIP=%3
	REM SET HTTP=%4

	ECHO %TEXT%
	IF EXIST %CHECK% EXIT /B
	IF NOT EXIST %CHECK% (
		IF NOT EXIST %ZIP% (
			ECHO Downloading %HTTP%...
			..\utils\httpget %HTTP% %ZIP%
		)
		..\utils\7z -bd -y x %ZIP%
		windows\bin\dfl -dfl-build
		IF NOT "%POST%"=="" (
			%POST%
		)
		IF NOT EXIST %CHECK% (
			ECHO Error installing PSPSDK
			EXIT /B
		)
	)
EXIT /B

REM bin\dsss net install dwt-win