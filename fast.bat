```bat
@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title YouTube Audio Downloader - Fast Auto Mode (WAV)

rem ============================================================
rem YouTube Audio Downloader - Fast Auto Mode
rem
rem Features:
rem - Fixed WAV (lossless audio) download
rem - No Y/N confirmation
rem - Download starts immediately after pressing Enter
rem - Multiple URLs supported on one line (comma-separated)
rem - Automatically excludes URLs whose titles cannot be retrieved
rem - Automatically retries failed items up to 3 times
rem ============================================================


rem ============================================================
rem INITIALIZE
rem ============================================================

set "APP_DIR=%~dp0"
cd /d "%APP_DIR%"

set "WORK_DIR=%TEMP%\YouTubeAudioDownloader_Fast\_%RANDOM%%RANDOM%"
set "QUEUE_FILE=!WORK_DIR!\queue.txt"
set "VALID_FILE=!WORK_DIR!\valid.txt"
set "FAILED_FILE=!WORK_DIR!\failed.txt"

mkdir "!WORK_DIR!" >nul 2>&1


rem ============================================================
rem REQUIRED FILE CHECK
rem ============================================================

if not exist "%APP_DIR%yt-dlp.exe" (
    echo.
    echo ============================================================
    echo [ERROR] yt-dlp.exe could not be found.
    echo.
    echo Expected path:
    echo %APP_DIR%yt-dlp.exe
    echo.
    echo Please place yt-dlp.exe in the program folder.
    echo ============================================================
    echo.
    pause
    goto EXIT
)

if not exist "%APP_DIR%ffmpeg.exe" (
    echo.
    echo ============================================================
    echo [ERROR] ffmpeg.exe could not be found.
    echo.
    echo Expected path:
    echo %APP_DIR%ffmpeg.exe
    echo.
    echo Please place ffmpeg.exe in the program folder.
    echo ============================================================
    echo.
    pause
    goto EXIT
)


rem ============================================================
rem LOAD CONFIG
rem ============================================================

call :LOAD_CONFIG
call :PREPARE_OUTPUT


rem ============================================================
rem MAIN SCREEN
rem ============================================================

:MAIN

call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo ============================================================
echo       YouTube Audio Downloader - Fast Auto Mode
echo ============================================================
echo.
echo Audio format : WAV (Lossless Audio)
echo Save location : !OUTPUT_PATH!
echo Input method  : URL or multiple comma-separated URLs
echo.
echo * Press Enter to start downloading immediately.
echo * URLs with unavailable titles will be skipped automatically.
echo.
echo help or ? = Help
echo.
echo ------------------------------------------------------------

set "INPUT="
set /p "INPUT=Enter URL(s)...: "

if not defined INPUT goto MAIN


rem ============================================================
rem COMMANDS
rem ============================================================

if /i "!INPUT!"=="help" goto HELP
if /i "!INPUT!"=="?" goto HELP

if /i "!INPUT!"=="exit" goto EXIT
if /i "!INPUT!"=="quit" goto EXIT


rem ============================================================
rem CREATE QUEUE
rem ============================================================

> "!QUEUE_FILE!" type nul
> "!VALID_FILE!" type nul
> "!FAILED_FILE!" type nul

set "REST=!INPUT!"

rem Convert commas to the internal *|* delimiter
set "REST=!REST:,=|!"


rem ============================================================
rem PARSE INPUT
rem ============================================================

:PARSE_INPUT

if not defined REST goto CHECK_QUEUE

set "TOKEN="
set "NEXT_REST="

for /f "tokens=1,* delims=|" %%A in ("!REST!") do (
    set "TOKEN=%%A"
    set "NEXT_REST=%%B"
)

set "REST=!NEXT_REST!"
set "TOKEN=!TOKEN:"=!"

if defined TOKEN (
    >> "!QUEUE_FILE!" echo(!TOKEN!
)

goto PARSE_INPUT


rem ============================================================
rem CHECK QUEUE
rem ============================================================

:CHECK_QUEUE

echo.
echo.
echo ============================================================
echo                       CHECKING URLS
echo ============================================================
echo.

set /a VALID_COUNT=0
set /a INVALID_COUNT=0

for /f "usebackq delims=" %%U in ("!QUEUE_FILE!") do (

    set "CURRENT_URL=%%U"
    set "TITLE="

    call :GET_TITLE

    if defined TITLE (

    set /a VALID_COUNT+=1

    echo [OK] !TITLE!
    >> "!VALID_FILE!" echo(!CURRENT_URL!

) else (

    set /a INVALID_COUNT+=1

    echo [SKIP] Could not retrieve the title:
    echo        !CURRENT_URL!
)
)


rem ============================================================
rem NO VALID URL
rem ============================================================

if !VALID_COUNT! EQU 0 (

    echo.
    echo ------------------------------------------------------------
    echo [CANCELLED] No downloadable URLs were found.
    echo ------------------------------------------------------------
    goto MAIN
)


rem ============================================================
rem DOWNLOAD START
rem ============================================================

echo.
echo ------------------------------------------------------------
echo Valid URLs   : !VALID_COUNT!
echo.
echo Skipped URLs : !INVALID_COUNT!
echo.
echo Starting download.
echo ------------------------------------------------------------
echo.


set /a ATTEMPT=0


rem ============================================================
rem RETRY LOOP
rem ============================================================

:DOWNLOAD_LOOP

set /a ATTEMPT+=1

> "!FAILED_FILE!" type nul

set /a SUCCESS_COUNT=0
set /a FAILED_COUNT=0
set /a CURRENT_INDEX=0


echo.
echo ============================================================
echo                    DOWNLOADING
echo ============================================================
echo.
echo Attempt : !ATTEMPT!/3
echo.


rem ============================================================
rem DOWNLOAD VALID URLs
rem ============================================================

for /f "usebackq delims=" %%U in ("!VALID_FILE!") do (

    set "CURRENT_URL=%%U"
    set /a CURRENT_INDEX+=1
    set "TITLE="

    call :GET_TITLE

    echo.
    echo ------------------------------------------------------------
    echo [!CURRENT_INDEX!] !TITLE!
    echo ------------------------------------------------------------

    call :DOWNLOAD_ONE

    if errorlevel 1 (

        echo [FAIL] Download failed
        >> "!FAILED_FILE!" echo(!CURRENT_URL!

        set /a FAILED_COUNT+=1

    ) else (

        echo [OK] Download successful

        set /a SUCCESS_COUNT+=1
    )
)


rem ============================================================
rem RETRY CHECK
rem ============================================================

if !FAILED_COUNT! EQU 0 goto DOWNLOAD_COMPLETE


if !ATTEMPT! GEQ 3 goto DOWNLOAD_FAILED_FINAL


echo.
echo ============================================================
echo                    AUTOMATIC RETRY
echo ============================================================
echo.
echo Failed items : !FAILED_COUNT!
echo.
echo Only failed items will be retried.
echo.

timeout /t 2 >nul

copy /y "!FAILED_FILE!" "!VALID_FILE!" >nul

goto DOWNLOAD_LOOP


rem ============================================================
rem DOWNLOAD COMPLETE
rem ============================================================

:DOWNLOAD_COMPLETE

echo.
echo.
echo ============================================================
echo                    DOWNLOAD COMPLETE
echo ============================================================
echo.
echo Successful : !SUCCESS_COUNT!
echo Failed     : !FAILED_COUNT!
echo Attempts   : !ATTEMPT!
echo.
echo Save location:
echo !OUTPUT_PATH!
echo.
echo ============================================================
echo.

goto MAIN


rem ============================================================
rem FINAL FAILURE
rem ============================================================

:DOWNLOAD_FAILED_FINAL

echo.
echo.
echo ============================================================
echo                    DOWNLOAD RESULTS
echo ============================================================
echo.
echo Automatic retry limit reached: 3 attempts.
echo.
echo Successful on final attempt : !SUCCESS_COUNT!
echo Failed on final attempt     : !FAILED_COUNT!
echo.
echo Failed URLs:
echo.

set /a FAIL_INDEX=0

for /f "usebackq delims=" %%U in ("!FAILED_FILE!") do (
    set /a FAIL_INDEX+=1
    echo [!FAIL_INDEX!] %%U
)

echo.
echo Save location:
echo !OUTPUT_PATH!
echo.
echo ============================================================
echo.

goto MAIN


rem ============================================================
rem GET TITLE
rem ============================================================

:GET_TITLE

set "TITLE="

for /f "delims=" %%A in (
    'yt-dlp.exe --print "%%(title)s" --skip-download --no-warnings "!CURRENT_URL!" 2^>nul'
) do (
    if not defined TITLE set "TITLE=%%A"
)

exit /b


rem ============================================================
rem DOWNLOAD ONE
rem ============================================================

:DOWNLOAD_ONE

if not defined CURRENT_URL exit /b 1

yt-dlp.exe ^
    -f "bestaudio/best" ^
    -x ^
    --audio-format wav ^
    --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
    -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
    "!CURRENT_URL!"

exit /b %ERRORLEVEL%


rem ============================================================
rem HELP
rem ============================================================

:HELP

echo.
echo.
echo ============================================================
echo          YouTube Audio Downloader - Fast Auto Mode
echo ============================================================
echo.
echo [USAGE]
echo.
echo Enter a YouTube or YouTube Music URL and
echo press Enter to start downloading immediately.
echo.
echo ------------------------------------------------------------
echo.
echo [SINGLE URL]
echo.
echo https://www.youtube.com/watch?v=...
echo.
echo ------------------------------------------------------------
echo.
echo [MULTIPLE URLs]
echo.
echo Multiple URLs can be entered on one line,
echo separated by commas (,).
echo.
echo Example:
echo https://example.com/1,https://example.com/2
echo.
echo ------------------------------------------------------------
echo.
echo [URL CHECK]
echo.
echo The title of each URL is checked before downloading.
echo.
echo URLs whose titles cannot be retrieved
echo will be excluded from the download list.
echo.
echo ------------------------------------------------------------
echo.
echo [DOWNLOAD]
echo.
echo Downloads are automatically converted to WAV
echo (lossless audio).
echo No Y/N confirmation is required.
echo.
echo ------------------------------------------------------------
echo.
echo [AUTOMATIC RETRY]
echo.
echo Failed downloads are automatically retried
echo up to 3 times.
echo.
echo Successful items are not downloaded again.
echo.
echo ------------------------------------------------------------
echo.
echo [COMMANDS]
echo.
echo help / ?
echo   Display help.
echo.
echo exit / quit
echo   Exit the program.
echo.
echo ============================================================
echo.

goto MAIN


rem ============================================================
rem LOAD CONFIG
rem ============================================================

:LOAD_CONFIG

set "OUTPUT="

if exist "%APP_DIR%config.txt" (

    for /f "usebackq tokens=1,* delims==" %%A in (
        "%APP_DIR%config.txt"
    ) do (
        if /i "%%A"=="output" set "OUTPUT=%%B"
    )
)

if not defined OUTPUT set "OUTPUT=Downloads"

exit /b


rem ============================================================
rem PREPARE OUTPUT
rem ============================================================

:PREPARE_OUTPUT

set "DEFAULT_OUTPUT=%APP_DIR%Downloads"


rem ------------------------------------------------------------
rem Reserved Downloads value
rem ------------------------------------------------------------

if /i "!OUTPUT!"=="Downloads" (

    set "OUTPUT_PATH=!DEFAULT_OUTPUT!"

    goto CREATE_OUTPUT
)


rem ------------------------------------------------------------
rem Absolute path
rem ------------------------------------------------------------

if "!OUTPUT:~1,1!"==":" (

    set "OUTPUT_PATH=!OUTPUT!"

    goto CHECK_OUTPUT
)


rem ------------------------------------------------------------
rem Relative path
rem ------------------------------------------------------------

set "OUTPUT_PATH=%APP_DIR%!OUTPUT!"

goto CHECK_OUTPUT


rem ============================================================
rem CHECK OUTPUT
rem ============================================================

:CHECK_OUTPUT

if exist "!OUTPUT_PATH!\." goto OUTPUT_OK

mkdir "!OUTPUT_PATH!" >nul 2>&1

if exist "!OUTPUT_PATH!\." goto OUTPUT_OK


rem ------------------------------------------------------------
rem Invalid path -> Downloads fallback
rem ------------------------------------------------------------

echo.
echo [WARNING] The selected download location could not be used.
echo [WARNING] Switching to the default Downloads folder.
echo.

set "OUTPUT=Downloads"
set "OUTPUT_PATH=!DEFAULT_OUTPUT!"

(
    echo # YouTube Audio Downloader Configuration
    echo quality=best
    echo output=Downloads
) > "%APP_DIR%config.txt"


rem ============================================================
rem CREATE DEFAULT OUTPUT
rem ============================================================

:CREATE_OUTPUT

if not exist "!OUTPUT_PATH!\." (
    mkdir "!OUTPUT_PATH!" >nul 2>&1
)

if not exist "!OUTPUT_PATH!\." (
    echo.
    echo [ERROR] Could not create the default Downloads folder.
    echo.
    exit /b 1
)

:OUTPUT_OK

exit /b


rem ============================================================
rem EXIT
rem ============================================================

:EXIT

echo.
echo Exiting the program.
echo.

if exist "!WORK_DIR!" (
    rd /s /q "!WORK_DIR!" >nul 2>&1
)

endlocal
exit /b
```