@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title YouTube Audio Downloader - Integrity Check & Installation (v0.3 Beta)
cls

echo ============================================================
echo  YouTube Audio Downloader (v0.3 Beta) - Self-Healing System
echo ============================================================
echo.

set "RAW_BASE_URL=https://raw.githubusercontent.com/KnowLessDogWalk/Youtube-Audio-Downloader/en"
set "SETUP_PATH=%~f0"
set "TEMP_DIR=%~dp0temp"

:: -----------------------------------------------------------
:: [1/6] Network Connection Check
:: -----------------------------------------------------------
echo [1/6] Checking network connection...

ping -n 1 8.8.8.8 >nul 2>&1

if !errorlevel! neq 0 (
    echo [ERROR] Internet connection is unavailable. Please check your network and try again.
    echo.
    pause
    exit /b
)

echo      - Internet connection: OK
echo.

:: -----------------------------------------------------------
:: [2/6] Temporary Folder & setup.bat Integrity Check
:: -----------------------------------------------------------
echo [2/6] Checking the integrity of setup.bat...

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
)

mkdir "%TEMP_DIR%" >nul 2>&1

if not exist "%TEMP_DIR%" (
    echo [ERROR] Failed to create the temporary folder.
    echo.
    pause
    exit /b
)

echo      - Downloading the latest setup.bat from GitHub...

curl -sS -f -L -o "%TEMP_DIR%\setup.bat" "%RAW_BASE_URL%/setup.bat"

if !errorlevel! neq 0 (
    echo [WARNING] Failed to download the latest setup.bat from GitHub.
    echo      - Continuing with the current setup.bat.
) else (
    call :GET_HASH "%SETUP_PATH%" CURRENT_SETUP_HASH
    call :GET_HASH "%TEMP_DIR%\setup.bat" REMOTE_SETUP_HASH

    if not defined CURRENT_SETUP_HASH (
        echo [ERROR] Failed to calculate the SHA-256 hash of the current setup.bat.
        echo.
        call :CLEANUP
        pause
        exit /b
    )

    if not defined REMOTE_SETUP_HASH (
        echo [ERROR] Failed to calculate the SHA-256 hash of the GitHub setup.bat.
        echo.
        call :CLEANUP
        pause
        exit /b
    )

    echo      - Current setup.bat SHA-256: !CURRENT_SETUP_HASH!
    echo      - GitHub setup.bat SHA-256: !REMOTE_SETUP_HASH!

    if /I "!CURRENT_SETUP_HASH!"=="!REMOTE_SETUP_HASH!" (
        echo      - setup.bat integrity: OK
    ) else (
        echo      - setup.bat integrity: MISMATCH
        echo      - Automatically restoring the latest setup.bat...

        copy /Y "%TEMP_DIR%\setup.bat" "%SETUP_PATH%" >nul

        if !errorlevel! neq 0 (
            echo [ERROR] Failed to restore setup.bat.
            echo.
            call :CLEANUP
            pause
            exit /b
        )

        echo      - setup.bat restoration complete.
        echo      - Restarting with the latest setup.bat...
        echo.

        call :CLEANUP

        start "" "%SETUP_PATH%"
        exit /b
    )
)

echo.

:: -----------------------------------------------------------
:: [3/6] yt-dlp.exe Engine Check & Update
:: -----------------------------------------------------------
echo [3/6] Checking and updating the yt-dlp download engine...

if not exist "yt-dlp.exe" (
    echo      - yt-dlp.exe not found. Downloading the latest build...

    curl -f -L -o "yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

    if !errorlevel! neq 0 (
        echo [WARNING] Failed to download yt-dlp.exe.
    ) else (
        echo      - yt-dlp.exe installation complete.
    )
) else (
    echo      - yt-dlp.exe found. Checking for the latest update...

    yt-dlp.exe -U

    if !errorlevel! neq 0 (
        echo [WARNING] Failed to update yt-dlp.exe.
    ) else (
        echo      - yt-dlp.exe update check complete.
    )
)

echo.

:: -----------------------------------------------------------
:: [4/6] ffmpeg.exe Audio Conversion Engine Check
:: -----------------------------------------------------------
echo [4/6] Checking the ffmpeg audio conversion engine...

if not exist "ffmpeg.exe" (
    echo      - ffmpeg.exe not found. Downloading the official package...

    curl -f -L -o "ffmpeg.zip" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"

    if !errorlevel! neq 0 (
        echo [WARNING] Failed to download the ffmpeg package.
    ) else (
        echo      - Extracting ffmpeg.exe from the archive...

        powershell -NoProfile -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_temp' -Force"

        if !errorlevel! neq 0 (
            echo [WARNING] Failed to extract the ffmpeg archive.
        ) else (
            powershell -NoProfile -Command "Get-ChildItem -Path 'ffmpeg_temp' -Filter 'ffmpeg.exe' -Recurse | Select-Object -First 1 | Copy-Item -Destination '.' -Force"

            if exist "ffmpeg.exe" (
                echo      - ffmpeg.exe extraction and installation complete.
            ) else (
                echo [WARNING] Failed to extract ffmpeg.exe. Conversion features may be limited.
            )
        )

        rmdir /s /q "ffmpeg_temp" >nul 2>&1
        del /f /q "ffmpeg.zip" >nul 2>&1
    )
) else (
    echo      - ffmpeg.exe: OK
)

echo.

:: -----------------------------------------------------------
:: [5/6] Program Files Temporary Download & Integrity Check
:: -----------------------------------------------------------
echo [5/6] Checking the integrity of the program files...
echo.

call :VERIFY_FILE "main.bat" "main.bat"
call :VERIFY_FILE "fast.bat" "fast.bat"
call :VERIFY_FILE "about.txt" "about.txt"
call :VERIFY_FILE "README.md" "README.md"

echo.

:: -----------------------------------------------------------
:: [6/6] Configuration File & Downloads Folder Setup
:: -----------------------------------------------------------
echo [6/6] Preparing the configuration file and Downloads folder...

if not exist "Downloads" (
    mkdir "Downloads"

    if !errorlevel! equ 0 (
        echo      - Downloads/ folder created.
    ) else (
        echo [WARNING] Failed to create the Downloads/ folder.
    )
) else (
    echo      - Downloads/ folder: Ready
)

if not exist "config.txt" (
    (
        echo # YouTube Audio Downloader Configuration
        echo quality=wav
        echo output=Downloads
    ) > "config.txt"

    if !errorlevel! equ 0 (
        echo      - Default config.txt configuration created.
    ) else (
        echo [WARNING] Failed to create config.txt.
    )
) else (
    echo      - config.txt configuration file: Ready
)

echo.

:: -----------------------------------------------------------
:: Temporary Folder Cleanup
:: -----------------------------------------------------------
echo      - Cleaning up temporary files...

call :CLEANUP

if exist "%TEMP_DIR%" (
    echo [WARNING] Failed to remove the temp folder.
) else (
    echo      - Temporary folder cleanup complete.
)

echo.

echo ============================================================
echo  All integrity checks and self-healing tasks are complete!
echo  You can now run main.bat or fast.bat to use the program.
echo ============================================================
echo.
pause
exit /b


:: ============================================================
:: Functions
:: ============================================================

:: -----------------------------------------------------------
:: Calculate SHA-256 Hash
::
:: Usage:
:: call :GET_HASH "file path" result_variable
:: -----------------------------------------------------------
:GET_HASH

set "%~2="

if not exist "%~1" (
    exit /b 1
)

for /f "tokens=1" %%H in ('certutil -hashfile "%~1" SHA256 ^| findstr /r /v /c:"SHA256" /c:"CertUtil"') do (
    set "%~2=%%H"
    goto :GET_HASH_DONE
)

:GET_HASH_DONE
exit /b


:: -----------------------------------------------------------
:: Download & Verify GitHub File
::
:: Usage:
:: call :VERIFY_FILE "local file" "GitHub file"
:: -----------------------------------------------------------
:VERIFY_FILE

set "LOCAL_FILE=%~1"
set "REMOTE_FILE=%~2"

echo      [%REMOTE_FILE%] Checking...

curl -sS -f -L -o "%TEMP_DIR%\%REMOTE_FILE%" "%RAW_BASE_URL%/%REMOTE_FILE%"

if !errorlevel! neq 0 (
    echo [ERROR] Failed to download %REMOTE_FILE% from GitHub.
    echo.
    exit /b
)

if not exist "%TEMP_DIR%\%REMOTE_FILE%" (
    echo [ERROR] Temporary copy of %REMOTE_FILE% was not created.
    echo.
    exit /b
)

:: -----------------------------------------------------------
:: Local File Missing
:: -----------------------------------------------------------
if not exist "%LOCAL_FILE%" (
    echo      - %LOCAL_FILE% missing -^> Automatically restoring from GitHub...

    copy /Y "%TEMP_DIR%\%REMOTE_FILE%" "%LOCAL_FILE%" >nul

    if !errorlevel! neq 0 (
        echo [ERROR] Failed to restore %LOCAL_FILE%.
    ) else (
        echo      - %LOCAL_FILE% restoration complete.
    )

    echo.
    exit /b
)

:: -----------------------------------------------------------
:: Calculate Local / Remote SHA-256
:: -----------------------------------------------------------
call :GET_HASH "%LOCAL_FILE%" LOCAL_HASH
call :GET_HASH "%TEMP_DIR%\%REMOTE_FILE%" REMOTE_HASH

if not defined LOCAL_HASH (
    echo [ERROR] Failed to calculate the SHA-256 hash of %LOCAL_FILE%.
    echo.
    exit /b
)

if not defined REMOTE_HASH (
    echo [ERROR] Failed to calculate the SHA-256 hash of the GitHub %REMOTE_FILE%.
    echo.
    exit /b
)

:: -----------------------------------------------------------
:: Compare SHA-256 Hashes
:: -----------------------------------------------------------
if /I "!LOCAL_HASH!"=="!REMOTE_HASH!" (
    echo      - %LOCAL_FILE%: OK
) else (
    echo      - %LOCAL_FILE% integrity mismatch -^> Restoring the latest version...

    copy /Y "%TEMP_DIR%\%REMOTE_FILE%" "%LOCAL_FILE%" >nul

    if !errorlevel! neq 0 (
        echo [ERROR] Failed to restore %LOCAL_FILE%.
    ) else (
        echo      - %LOCAL_FILE% restoration complete.
    )
)

echo.
exit /b


:: -----------------------------------------------------------
:: Temporary Folder Cleanup
:: -----------------------------------------------------------
:CLEANUP

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
)

exit /b
