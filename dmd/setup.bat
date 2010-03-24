@ECHO OFF
SET PATH="%CD%\bin";%PATH%

GOTO START

	:POST_DMD
		RD /Q /S html > NUL 2> NUL
		MOVE dmd2\html > NUL 2> NUL

		RD /Q /S samples > NUL 2> NUL
		MOVE dmd2\samples > NUL 2> NUL

		RD /Q /S src > NUL 2> NUL
		MOVE dmd2\src > NUL 2> NUL

		RD /Q /S windows > NUL 2> NUL
		MOVE dmd2\windows > NUL 2> NUL

		RD /Q /S license.txt > NUL 2> NUL
		MOVE dmd2\license.txt > NUL 2> NUL

		RD /Q /S README.txt > NUL 2> NUL
		MOVE dmd2\README.TXT > NUL 2> NUL

		RD /Q /S dmd2 > NUL 2> NUL
	EXIT /B

	:POST_DFL
		windows\bin\dfl -dfl-build
	EXIT /B

	:POST_SDK
	EXIT /B

	:POST_DDBG
		DEL /Q /S windows\bin\ddbg.exe > NUL 2> NUL
		MOVE ddbg.exe windows\bin
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
			%POST%
			IF NOT EXIST %CHECK% (
				ECHO Error installing %NAME%
				EXIT /B
			)
		)
	EXIT /B

:START

REM SET DSSS_HTTP=http://svn.dsource.org/projects/dsss/downloads/0.78/dsss-0.78-x86-windows.zip

REM ---------------------------------------------------------------------------
REM http://www.digitalmars.com/d/2.0/changelog.html
SET NAME=DMD
SET TEXT=Preparing DMD...
SET CHECK=windows\bin\dmd.exe
SET ZIP=dmd.2.042.zip
REM SET HTTP=http://pspemu.googlecode.com/files/dmd.2.040.zip
SET HTTP=http://ftp.digitalmars.com/dmd.2.042.zip
SET POST=CALL :POST_DMD
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------
REM http://www.dprogramming.com/dfl.php
SET NAME=DFL
SET TEXT=Preparing DFL...
SET CHECK=windows\bin\dfl.exe
SET ZIP=dfl_dmd2040.7z
REM SET HTTP=http://www.dprogramming.com/dfl/snapshots/dfl-20090411.zip
SET HTTP=http://pspemu.googlecode.com/files/dfl_dmd2040.7z
SET POST=CALL :POST_DFL
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------
REM http://minpspw.sourceforge.net/
SET NAME=SDK
SET TEXT=Preparing PSPSDK...
SET CHECK=pspsdk\bin\psp-gcc.exe
SET ZIP=pspsdk.7z
SET HTTP=http://pspemu.googlecode.com/files/pspsdk.7z
SET POST=CALL :POST_SDK
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------
REM http://ddbg.mainia.de/releases.html
SET NAME=DDBG
SET TEXT=Preparing DDBG...
SET CHECK=windows\bin\ddbg.exe
SET ZIP=Ddbg-0.11.3-beta.zip
SET HTTP=http://pspemu.googlecode.com/files/Ddbg-0.11.3-beta.zip
SET POST=CALL :POST_DDBG
CALL :INSTALL_PAK

REM ---------------------------------------------------------------------------

EXIT /B
