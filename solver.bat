@echo off
setlocal enabledelayedexpansion

REM Check if required folders exist
if not exist "mysql\data\" (
    echo Error: mysql\data folder does not exist!
    pause
    exit /b 1
)

if not exist "mysql\backup\" (
    echo Error: mysql\backup folder does not exist!
    pause
    exit /b 1
)

REM Step 1: Rename mysql/data to mysql/data_old
if exist "mysql\data_old\" (
    echo Error: mysql\data_old already exists!
    pause
    exit /b 1
)
rename "mysql\data" "data_old" || (
    echo Failed to rename data to data_old
    pause
    exit /b 1
)

REM Step 2: Make a copy of mysql/backup and name it mysql/data
xcopy /E /I /H /K /Y "mysql\backup" "mysql\data\" || (
    echo Failed to copy backup to data
    pause
    exit /b 1
)

REM Step 3: Copy all database folders from mysql/data_old into mysql/data
for /D %%F in ("mysql\data_old\*") do (
    set "folder=%%~nxF"
    if /I not "!folder!"=="mysql" (
        if /I not "!folder!"=="performance_schema" (
            if /I not "!folder!"=="phpmyadmin" (
                xcopy /E /I /H /K /Y "%%F" "mysql\data\!folder!\" || (
                    echo Failed to copy folder !folder!
                )
            )
        )
    )
)

REM Step 4: Copy ibdata1 from data_old to data
if exist "mysql\data_old\ibdata1" (
    copy /Y "mysql\data_old\ibdata1" "mysql\data\" || (
        echo Failed to copy ibdata1
    )
) else (
    echo Warning: ibdata1 not found in data_old
)

echo Operation completed successfully
pause