REM Identify integrity and file class by extracting images 1 and 17
REM If image 1 is not extracted move the file to \error\
REM If image 17 is not extracted consider it abyssal
REM The order is important as a file could have mismatching tags in 1. 
@ECHO OFF
SETLOCAL
SET ME=%~n0
SET PARENT=%~dp0

ECHO Running %ME%>CON
ECHO Running %ME%

IF NOT EXIST "%PARENT%temp\abyssal" MKDIR "%PARENT%temp\abyssal"
IF NOT EXIST "%PARENT%temp\kanmusu" MKDIR "%PARENT%temp\kanmusu"
IF NOT EXIST "%PARENT%temp\abyssal_mod" MKDIR "%PARENT%temp\abyssal_mod"
IF NOT EXIST "%PARENT%temp\kanmusu_mod" MKDIR "%PARENT%temp\kanmusu_mod"
IF NOT EXIST "%PARENT%temp\special" MKDIR "%PARENT%temp\special"

SET _SPECIAL="%PARENT%data\special"
SET BLOCKSIZE=5
FOR /F "tokens=1* delims=[]" %%g in ('DIR /A-D /B *.swf ^|find /v /n ""') DO (
	COPY /y "%%~nxh" "%PARENT%temp"
	ECHO Importing file %%g of %BLOCKSIZE%...
	ECHO Importing file %%g of %BLOCKSIZE%...>CON
	if %%g==%BLOCKSIZE% GOTO SORTING
)



:SORTING
CD temp

REM Redirect all SPECIAL files on the list
FOR /f %%f in ('TYPE "%_SPECIAL%"') DO (
	MOVE /y "%%f" "%PARENT%temp\special" 2>nul
	IF %errorlevel%===0 ECHO Special file %%f found, redirecting...
)

REM Rename *.hack.swf to *.hack to isolate two streams
REN *hack.swf *hack
For %%f in (*.swf) DO (
	java -jar "%PARENT%bin\ffdec\ffdec.jar" -onerror ignore -format image:png -selectid 1 -export image "%PARENT%temp" "%%f"
	java -jar "%PARENT%bin\ffdec\ffdec.jar" -onerror ignore -format image:png -selectid 11 -export image "%PARENT%temp" "%%f"
	java -jar "%PARENT%bin\ffdec\ffdec.jar" -onerror ignore -format image:png -selectid 17 -export image "%PARENT%temp" "%%f"
	IF NOT EXIST "%PARENT%temp\1.png" (
		ECHO Failed to detect file type of %%f, skipping this file...>con
		ECHO Failed to detect file type of %%f, skipping this file...
		COPY "%%f" "%PARENT%error\"
	) ELSE IF NOT EXIST "%PARENT%temp\11.png" (
		ECHO %%f is an ABYSSAL STOCK sprite pack>con
		ECHO %%f is an ABYSSAL STOCK sprite pack
		COPY "%%f" "%PARENT%temp\abyssal\"
	) ELSE (
		ECHO %%f is a KANMUSU STOCK sprite pack>con
		ECHO %%f is a KANMUSU STOCK sprite pack
		COPY "%%f" "%PARENT%temp\kanmusu\"
	)
	DEL /q "%PARENT%temp\*.png"
)

For %%f in (*.hack) DO (
	java -jar "%PARENT%bin\ffdec\ffdec.jar" -onerror ignore -format image:png -selectid 1 -export image "%PARENT%temp" "%%f"
	java -jar "%PARENT%bin\ffdec\ffdec.jar" -onerror ignore -format image:png -selectid 17 -export image "%PARENT%temp" "%%f"
	IF NOT EXIST "%PARENT%temp\1.png" (
		ECHO Failed to detect file type of %%f, skipping this file...>con
		ECHO Failed to detect file type of %%f, skipping this file...
		REN "%%f" "%%f.swf"
		COPY "%%f.swf" "%PARENT%error\"
	) ELSE IF NOT EXIST "%PARENT%temp\17.png" (
		ECHO %%f is an ABYSSAL MOD sprite pack>con
		ECHO %%f is an ABYSSAL MOD sprite pack
		REN "%%f" "%%f.swf"
		COPY "%%f.swf" "%PARENT%temp\abyssal_mod\"
	) ELSE (
		ECHO %%f is a KANMUSU MOD sprite pack>con
		ECHO %%f is a KANMUSU MOD sprite pack
		REN "%%f" "%%f.swf"
		COPY "%%f.swf" "%PARENT%temp\kanmusu_mod\"
	)
	DEL /q "%PARENT%temp\*.png"
)

REM Remove files in staging area after sorting
DEL /q "%PARENT%temp\*.swf"
DEL /q "%PARENT%temp\*.hack"

ENDLOCAL
EXIT /B 0