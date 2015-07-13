@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
SET ME=%~n0
SET PARENT=%~dp0

ECHO Preparing folders...
CALL CLEANUP > nul 2>&1
MKDIR temp
MKDIR output

ECHO Checking scripts...
FOR /F %%f in ('type data\modules') DO (
	IF NOT EXIST %%f ECHO %%F is missing && GOTO GENERIC_FAIL
)

ECHO Testing modules...
CALL SELFTEST > selftest.log 2>&1
if %errorlevel% neq 0 GOTO GENERIC_FAIL

:AUTOPROCESS
ECHO Looking for files to import...
IF NOT EXIST *.swf ECHO There are no files left to import, exiting autoprocess && GOTO ERROR_RECOVERY 
ECHO Importing files...
CALL IMPORT > import.log 2>&1
CALL EXTRACT > extract.log 2>&1
CALL SCALE 2> scale.log
CALL REPLACE > replace.log 2>&1
CALL EXPORT > export.log 2>&1
GOTO AUTOPROCESS

:ERROR_RECOVERY
MOVE /y "%PARENT%error\*.swf" "%PARENT%"
ECHO Retrying once
IF NOT EXIST *.swf ECHO There are no files left to recover, exiting && GOTO NORMAL_EXIT 
ECHO Importing files...
CALL IMPORT > import.log 2>&1
CALL EXTRACT > extract.log 2>&1
CALL SCALE 2> scale.log
CALL REPLACE > replace.log 2>&1
CALL EXPORT > export.log 2>&1
GOTO ERROR_RECOVERY

:NORMAL_EXIT
CD %PARENT%
ECHO Saving log to log_lastrun.txt...
COPY selftest.log + import.log + extract.log + scale.log + replace.log log_lastrun.txt > nul 2>&1
ECHO Removing temporary files...
CALL CLEANUP > nul 2>&1
ENDLOCAL
ECHO ----------------
ECHO Process Complete
ECHO ----------------
PAUSE
EXIT /B 0

:GENERIC_FAIL
ENDLOCAL
ECHO -----------------
ECHO Process Failed :(
ECHO -----------------
PAUSE
EXIT /B 1