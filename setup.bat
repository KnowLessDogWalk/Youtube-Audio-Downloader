@echo off
chcp 65001 >nul
title YouTube Audio Downloader - Integrity Check & Installation (v0.3 Beta)
cls

echo ============================================================
echo  YouTube Audio Downloader (v0.3 Beta) - Self-Healing System
echo ============================================================
echo.

set "RAW_BASE_URL=https://raw.githubusercontent.com/KnowLessDogWalk/Youtube-Audio-Downloader/en"

:: -----------------------------------------------------------
:: [1/5] Network Connection Check
:: -----------------------------------------------------------
echo [1/5] Checking network connection...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Internet connection is unavailable. Please check your network and try again.
    echo.
    pause
    exit /b
)
echo      - Internet connection: OK
echo.

:: -----------------------------------------------------------
:: [2/5] yt-dlp.exe Engine Check & Update
:: -----------------------------------------------------------
echo [2/5] Checking and updating the yt-dlp download engine...
if not exist "yt-dlp.exe" (
    echo      - yt-dlp.exe not found. Downloading the latest build...
    curl -L -o "yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to download yt-dlp.exe.
    ) else (
        echo      - yt-dlp.exe installation complete.
    )
) else (
    echo      - yt-dlp.exe found. Checking for the latest update...
    yt-dlp.exe -U
)
echo.

:: -----------------------------------------------------------
:: [3/5] ffmpeg.exe Audio Conversion Engine Check
:: -----------------------------------------------------------
echo [3/5] Checking for the ffmpeg audio conversion engine...
if not exist "ffmpeg.exe" (
    echo      - ffmpeg.exe not found. Downloading the official package...
    curl -L -o "ffmpeg.zip" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    echo      - Extracting ffmpeg.exe from the archive...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_temp' -Force"
    powershell -Command "Get-ChildItem -Path 'ffmpeg_temp' -Filter 'ffmpeg.exe' -Recurse | Copy-Item -Destination '.'"
    rmdir /s /q "ffmpeg_temp" >nul 2>&1
    del /f /q "ffmpeg.zip" >nul 2>&1
    if exist "ffmpeg.exe" (
        echo      - ffmpeg.exe extraction and installation complete.
    ) else (
        echo [WARNING] Failed to extract ffmpeg.exe. Conversion features may be limited.
    )
) else (
    echo      - ffmpeg.exe: OK
)
echo.

:: -----------------------------------------------------------
:: [4/5] Main Script Integrity Check
:: -----------------------------------------------------------
echo [4/5] Checking the integrity of the main scripts (main.bat, fast.bat)...

if not exist "main.bat" (
    echo      - main.bat missing -> Automatically restoring from the GitHub repository...
    curl -s -L -o "main.bat" "%RAW_BASE_URL%/main.bat"
    if exist "main.bat" (
        echo      - main.bat restoration complete.
    ) else (
        echo [ERROR] Failed to restore main.bat. Please check the remote repository.
    )
) else (
    echo      - main.bat: OK
)

if not exist "fast.bat" (
    echo      - fast.bat missing -> Automatically restoring from the GitHub repository...
    curl -s -L -o "fast.bat" "%RAW_BASE_URL%/fast.bat"
    if exist "fast.bat" (
        echo      - fast.bat restoration complete.
    ) else (
        echo [ERROR] Failed to restore fast.bat. Please check the remote repository.
    )
) else (
    echo      - fast.bat: OK
)
echo.

:: -----------------------------------------------------------
:: [5/5] Configuration File & Downloads Folder Setup
:: -----------------------------------------------------------
echo [5/5] Preparing the configuration file and Downloads folder...

if not exist "Downloads" (
    mkdir "Downloads"
    echo      - Downloads/ folder created.
) else (
    echo      - Downloads/ folder: Ready
)

if not exist "config.txt" (
    (
        echo # YouTube Audio Downloader Configuration
        echo quality=wav
        echo output=Downloads
    ) > "config.txt"
    echo      - Default config.txt configuration created.
) else (
    echo      - config.txt configuration file: Ready
)

if not exist "about.txt" (
    echo      - about.txt missing -> Restoring from GitHub remote repository...
    curl -s -L -o "about.txt" "%RAW_BASE_URL%/about.txt"
    if exist "about.txt" (
        echo      - about.txt restored successfully.
    ) else (
        echo [ERROR] Failed to restore about.txt. Please check the remote repository.
    )
) else (
    echo      - about.txt: OK
)
echo.

echo ============================================================
echo  All integrity checks and self-healing tasks are complete!
echo  You can now run main.bat or fast.bat to use the program.
echo ============================================================
echo.
pause
