```bat
@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title YouTube Audio Downloader

rem ============================================================
rem YouTube Audio Downloader - Beta
rem ============================================================

set "APP_DIR=%~dp0"
set "WORK_DIR=%TEMP%\YouTubeAudioDownloader_%RANDOM%%RANDOM%"
set "QUEUE_FILE=!WORK_DIR!\queue.txt"
set "VALID_FILE=!WORK_DIR!\valid.txt"
set "FAILED_FILE=!WORK_DIR!\failed.txt"
set "SIZE_FILE=!WORK_DIR!\sizes.txt"

mkdir "!WORK_DIR!" >nul 2>&1

if not exist "%APP_DIR%yt-dlp.exe" (
    echo.
    echo [ERROR] yt-dlp.exe could not be found.
    echo.
    pause
    exit /b
)

if not exist "%APP_DIR%config.txt" (
    (
        echo # YouTube Audio Downloader Configuration
        echo quality=best
        echo output=Downloads
    ) > "%APP_DIR%config.txt"
)

if not exist "%APP_DIR%about.txt" (
    (
        echo YouTube Audio Downloader
        echo.
        echo Enter a description of this program here.
    ) > "%APP_DIR%about.txt"
)

call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo ============================================================
echo                   YouTube Audio Downloader
echo ============================================================
echo.
echo Current quality : !QUALITY!
echo Download folder : !OUTPUT_PATH!
echo.
echo Type help or ? to view the help menu.
echo.
echo ------------------------------------------------------------

:MAIN
call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
set "INPUT="
set /p "INPUT=Enter a URL or command...: "

if not defined INPUT goto MAIN

if /i "!INPUT!"=="setting" goto SETTING
if /i "!INPUT!"=="set" goto SETTING

if /i "!INPUT!"=="config" goto CONFIG
if /i "!INPUT!"=="con" goto CONFIG

if /i "!INPUT!"=="about" goto ABOUT
if /i "!INPUT!"=="abo" goto ABOUT

if /i "!INPUT!"=="help" goto HELP
if /i "!INPUT!"=="?" goto HELP

if /i "!INPUT!"=="multi" goto MULTI
if /i "!INPUT!"=="mul" goto MULTI

if /i "!INPUT!"=="exit" goto EXIT
if /i "!INPUT!"=="quit" goto EXIT

set "CURRENT_URL=!INPUT!"
goto SINGLE_DOWNLOAD


rem ============================================================
rem SETTINGS
rem ============================================================

:SETTING
call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo.
echo ============================================================
echo                         SETTINGS
echo ============================================================
echo.
echo Current quality : !QUALITY!
echo Download folder : !OUTPUT_PATH!
echo.
echo [1] Change quality
echo [2] Change download folder
echo [B] Back
echo.

set "SETTING_INPUT="
set /p "SETTING_INPUT=Select an option...: "

if /i "!SETTING_INPUT!"=="b" goto MAIN
if /i "!SETTING_INPUT!"=="exit" goto MAIN
if /i "!SETTING_INPUT!"=="quit" goto MAIN
if "!SETTING_INPUT!"=="1" goto CHANGE_QUALITY
if "!SETTING_INPUT!"=="2" goto CHANGE_OUTPUT

echo.
echo [ERROR] Invalid selection.
goto SETTING


rem ============================================================
rem CHANGE QUALITY
rem ============================================================

:CHANGE_QUALITY
echo.
echo ------------------------------------------------------------
echo Available quality options
echo.
echo [1] original = Original audio (no conversion)
echo [2] best     = Best quality MP3 (VBR)
echo [3] 320k     = MP3 320 kbps
echo [4] 256k     = MP3 256 kbps
echo [5] 192k     = MP3 192 kbps
echo [6] wav      = WAV lossless audio (recommended for DAW)
echo.

set "NEW_QUALITY="
set /p "NEW_QUALITY=Enter a number...: "

if /i "!NEW_QUALITY!"=="exit" goto MAIN
if /i "!NEW_QUALITY!"=="quit" goto MAIN

if "!NEW_QUALITY!"=="1" set "NEW_QUALITY=original"
if "!NEW_QUALITY!"=="2" set "NEW_QUALITY=best"
if "!NEW_QUALITY!"=="3" set "NEW_QUALITY=320k"
if "!NEW_QUALITY!"=="4" set "NEW_QUALITY=256k"
if "!NEW_QUALITY!"=="5" set "NEW_QUALITY=192k"
if "!NEW_QUALITY!"=="6" set "NEW_QUALITY=wav"

if /i "!NEW_QUALITY!"=="original" goto SAVE_QUALITY
if /i "!NEW_QUALITY!"=="best" goto SAVE_QUALITY
if /i "!NEW_QUALITY!"=="320k" goto SAVE_QUALITY
if /i "!NEW_QUALITY!"=="256k" goto SAVE_QUALITY
if /i "!NEW_QUALITY!"=="192k" goto SAVE_QUALITY
if /i "!NEW_QUALITY!"=="wav" goto SAVE_QUALITY

echo.
echo [ERROR] Invalid number.
goto CHANGE_QUALITY

:SAVE_QUALITY
set "QUALITY=!NEW_QUALITY!"
call :SAVE_CONFIG
call :LOAD_CONFIG

echo.
echo [OK] Quality changed to !QUALITY!.
echo [OK] config.txt has been updated.
goto SETTING


rem ============================================================
rem CHANGE OUTPUT
rem ============================================================

:CHANGE_OUTPUT
echo.
echo ------------------------------------------------------------
echo Current download folder:
echo !OUTPUT_PATH!
echo.
echo Default Downloads folder:
echo %APP_DIR%Downloads
echo.
echo Enter the path of the folder you want to use.
echo.
echo Examples:
echo C:\Users\YourName\Downloads
echo D:\Music\YouTube
echo.
echo Quoted paths are also supported.
echo Example: "C:\Users\YourName\Downloads"
echo.
echo help or ? = path copy guide
echo exit or quit = return to main screen
echo.

set "NEW_OUTPUT="
set /p "NEW_OUTPUT=Enter download folder...: "

if not defined NEW_OUTPUT goto CHANGE_OUTPUT

if /i "!NEW_OUTPUT!"=="help" goto OUTPUT_HELP
if /i "!NEW_OUTPUT!"=="?" goto OUTPUT_HELP
if /i "!NEW_OUTPUT!"=="exit" goto MAIN
if /i "!NEW_OUTPUT!"=="quit" goto MAIN

set "NEW_OUTPUT=!NEW_OUTPUT:"=!"
set "OUTPUT=!NEW_OUTPUT!"

call :SAVE_CONFIG
call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo [OK] Download folder changed.
echo [OK] Configuration value: !OUTPUT!
echo [OK] Actual path: !OUTPUT_PATH!
echo [OK] config.txt has been updated.
goto SETTING


:OUTPUT_HELP
echo.
echo.
echo ============================================================
echo                    DOWNLOAD PATH HELP
echo ============================================================
echo.
echo How to copy a folder path in Windows
echo.
echo Method 1:
echo 1. Open the desired folder in File Explorer.
echo 2. Click the address bar at the top.
echo 3. Press Ctrl + A.
echo 4. Press Ctrl + C to copy the path.
echo 5. Return to this window and press Ctrl + V.
echo.
echo Method 2:
echo 1. Shift + right-click inside the desired folder.
echo 2. Select "Copy as path".
echo 3. Press Ctrl + V in this window.
echo.
echo Quoted paths are also supported.
echo.
echo Example:
echo "C:\Users\YourName\Downloads"
echo.
echo ------------------------------------------------------------
pause
goto CHANGE_OUTPUT


rem ============================================================
rem CONFIG / ABOUT
rem ============================================================

:CONFIG
echo.
echo.
echo ============================================================
echo                         CONFIG
echo ============================================================
echo.
type "%APP_DIR%config.txt"
echo.
echo ------------------------------------------------------------
goto MAIN

:ABOUT
echo.
echo.
echo ============================================================
echo                         ABOUT
echo ============================================================
echo.
type "%APP_DIR%about.txt"
echo.
echo ------------------------------------------------------------
goto MAIN


rem ============================================================
rem HELP
rem ============================================================

:HELP
echo.
echo.
echo ============================================================
echo                         HELP
echo ============================================================
echo.
echo [COMMANDS]
echo.
echo set / setting
echo   Open the settings menu.
echo.
echo con / config
echo   Display the contents of config.txt.
echo.
echo abo / about
echo   Display the contents of about.txt.
echo.
echo multi / mul
echo   Enter multiple URLs at once.
echo.
echo help / ?
echo   Display this help menu.
echo.
echo exit / quit
echo   Exit the program from the main screen,
echo   or return to the main screen from a submenu.
echo.
echo ------------------------------------------------------------
echo.
echo [SINGLE DOWNLOAD]
echo.
echo Enter a YouTube or YouTube Music URL.
echo The title will be checked before asking for confirmation.
echo.
echo If the title cannot be retrieved, the download is cancelled.
echo.
echo ------------------------------------------------------------
echo.
echo [MULTI DOWNLOAD]
echo.
echo Type multi or mul to open multi-download mode.
echo.
echo URLs can be entered on separate lines.
echo.
echo Type dl or download when you are finished entering URLs.
echo.
echo clear = remove all currently entered URLs
echo help / ? = multi-download help
echo.
echo ------------------------------------------------------------
echo.
echo [MULTI DOWNLOAD PREVIEW]
echo.
echo The title, estimated size, and total estimated size
echo will be displayed before downloading.
echo.
echo Enter Y to download the URLs one by one in order.
echo.
echo ------------------------------------------------------------
echo.
echo [REDOWNLOAD]
echo.
echo After downloading, the following options are available.
echo.
echo [1] Retry failed items only
echo [2] Delete existing files and download all items again
echo [3] Download all items again without deleting existing files
echo [4] Return to the main screen
echo.
echo ------------------------------------------------------------
echo.
echo [QUALITY]
echo.
echo original
echo   Saves the available original audio stream without conversion.
echo.
echo best
echo   Converts the audio to the best-quality MP3 VBR.
echo.
echo 320k
echo   MP3 320 kbps
echo.
echo 256k
echo   MP3 256 kbps
echo.
echo 192k
echo   MP3 192 kbps
echo.
echo wav
echo   Converts the audio to WAV lossless format (recommended for DAW).
echo.
echo ============================================================
echo.
goto MAIN


rem ============================================================
rem SINGLE DOWNLOAD
rem ============================================================

:SINGLE_DOWNLOAD
call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo.
echo ============================================================
echo                     CHECKING URL
echo ============================================================
echo.

set "TITLE="
set "SOURCE_SIZE="

call :GET_INFO

if not defined TITLE (
    echo.
    echo [CANCELLED]
    echo Could not retrieve the title.
    echo Download cancelled.
    echo.
    echo ------------------------------------------------------------
    goto MAIN
)

echo Title        : !TITLE!
echo Quality      : !QUALITY!
echo Download to  : !OUTPUT_PATH!

if defined SOURCE_SIZE (
    call :FORMAT_SIZE "!SOURCE_SIZE!"
    echo Estimated size : !DISPLAY_SIZE!
)

echo.

if /i "!QUALITY!"=="wav" (
    echo Download "!TITLE!" as "WAV lossless audio"? [Y/N]
) else if /i "!QUALITY!"=="original" (
    echo Download "!TITLE!" as "Original audio"? [Y/N]
) else if /i "!QUALITY!"=="best" (
    echo Download "!TITLE!" as "Best quality MP3"? [Y/N]
) else (
    echo Download "!TITLE!" as "MP3 !QUALITY!"? [Y/N]
)

echo.

set "CONFIRM="
set /p "CONFIRM=> "

if /i "!CONFIRM!"=="n" goto CANCEL_DOWNLOAD
if /i "!CONFIRM!"=="y" goto START_SINGLE_BATCH

echo.
echo [ERROR] Please enter Y or N.
goto SINGLE_DOWNLOAD


:START_SINGLE_BATCH
> "!VALID_FILE!" echo !CURRENT_URL!
goto EXECUTE_BATCH


:CANCEL_DOWNLOAD
echo.
echo [CANCELLED] Download skipped.
echo.
echo ------------------------------------------------------------
goto MAIN


rem ============================================================
rem MULTI DOWNLOAD
rem ============================================================

:MULTI
call :LOAD_CONFIG
call :PREPARE_OUTPUT

> "!QUEUE_FILE!" type nul
> "!VALID_FILE!" type nul
> "!FAILED_FILE!" type nul
> "!SIZE_FILE!" type nul

echo.
echo.
echo ============================================================
echo                    MULTI DOWNLOAD
echo ============================================================
echo.
echo Enter your URLs.
echo.
echo - Enter one URL per line.
echo - Multiple URLs can be pasted at once.
echo - URLs can also be entered across multiple lines.
echo.
echo Type dl or download when finished.
echo clear = remove all entered URLs
echo help or ? = help
echo.
echo list = show current URL list
echo exit or quit = return to main screen
echo.
echo ------------------------------------------------------------

:MULTI_INPUT
set "MULTI_INPUT="
set /p "MULTI_INPUT=multi> "

if not defined MULTI_INPUT goto MULTI_INPUT

if /i "!MULTI_INPUT!"=="dl" goto MULTI_PREVIEW
if /i "!MULTI_INPUT!"=="download" goto MULTI_PREVIEW

if /i "!MULTI_INPUT!"=="list" goto MULTI_LIST

if /i "!MULTI_INPUT!"=="clear" (
    > "!QUEUE_FILE!" type nul
    echo.
    echo [OK] All entered URLs have been cleared.
    goto MULTI_INPUT
)

if /i "!MULTI_INPUT!"=="help" goto MULTI_HELP
if /i "!MULTI_INPUT!"=="?" goto MULTI_HELP

if /i "!MULTI_INPUT!"=="exit" goto MAIN
if /i "!MULTI_INPUT!"=="quit" goto MAIN

call :ADD_MULTI_LINE

goto MULTI_INPUT


:ADD_MULTI_LINE
set "REST=!MULTI_INPUT!"
set "REST=!REST:|||=|!"
set "REST=!REST:,=|!"

:ADD_MULTI_NEXT
if not defined REST exit /b

set "TOKEN="
for /f "tokens=1,* delims=|" %%A in ("!REST!") do (
    set "TOKEN=%%A"
    set "REST=%%B"
)

set "TOKEN=!TOKEN:"=!"

if defined TOKEN (
    >> "!QUEUE_FILE!" echo(!TOKEN!
    echo [ADD] !TOKEN!
)

goto ADD_MULTI_NEXT


:MULTI_LIST

echo.
echo.
echo ============================================================
echo                     URL LIST
echo ============================================================
echo.

set "LIST_COUNT=0"

for /f "usebackq delims=" %%A in ("!QUEUE_FILE!") do (
    set /a LIST_COUNT+=1
    echo [!LIST_COUNT!] %%A
)

if "!LIST_COUNT!"=="0" (
    echo [INFO] No URLs have been entered.
)

echo.
echo ------------------------------------------------------------
goto MULTI_INPUT


:MULTI_HELP
echo.
echo.
echo ============================================================
echo                    MULTI DOWNLOAD HELP
echo ============================================================
echo.
echo URL input example:
echo.
echo https://example.com/1
echo https://example.com/2
echo.
echo Multiple URLs can be entered across multiple lines.
echo.
echo dl / download
echo   Check the entered URLs and start downloading.
echo.
echo clear
echo   Remove all currently entered URLs.
echo.
echo exit / quit
echo   Return to the main screen.
echo.
echo list
echo   Display the currently entered URL list.
echo.
echo ------------------------------------------------------------
goto MULTI_INPUT


rem ============================================================
rem MULTI PREVIEW
rem ============================================================

:MULTI_PREVIEW
> "!VALID_FILE!" type nul
> "!SIZE_FILE!" type nul

set /a ITEM_COUNT=0
set /a VALID_COUNT=0

echo.
echo.
echo ============================================================
echo                    DOWNLOAD LIST
echo ============================================================
echo.
echo Checking titles and estimated sizes...
echo.

for /f "usebackq delims=" %%U in ("!QUEUE_FILE!") do (
    set "CURRENT_URL=%%U"
    call :GET_INFO

    if defined TITLE (
        set /a ITEM_COUNT+=1
        set /a VALID_COUNT+=1

        call :FORMAT_SIZE "!SOURCE_SIZE!"

        echo [!ITEM_COUNT!] !TITLE!
        echo     Size: !DISPLAY_SIZE!
        echo.

        >> "!VALID_FILE!" echo(!CURRENT_URL!
        if defined SOURCE_SIZE >> "!SIZE_FILE!" echo !SOURCE_SIZE!
    ) else (
        echo [SKIP] Could not retrieve the title:
        echo        !CURRENT_URL!
        echo        This URL will be excluded from the download list.
        echo.
    )
)

if !VALID_COUNT! EQU 0 (
    echo [CANCELLED] No downloadable items were found.
    echo.
    echo ------------------------------------------------------------
    goto MAIN
)

call :CALCULATE_TOTAL_SIZE

echo ------------------------------------------------------------
echo Total items : !VALID_COUNT!
echo Total estimated size : !TOTAL_SIZE!
echo ------------------------------------------------------------
echo.
echo Download the above items in order? [Y/N]
echo.

set "CONFIRM="
set /p "CONFIRM=> "

if /i "!CONFIRM!"=="n" goto MAIN
if /i "!CONFIRM!"=="y" goto EXECUTE_BATCH

echo.
echo [ERROR] Please enter Y or N.
goto MULTI_PREVIEW


rem ============================================================
rem EXECUTE BATCH
rem ============================================================

:EXECUTE_BATCH
call :LOAD_CONFIG
call :PREPARE_OUTPUT

> "!FAILED_FILE!" type nul
set /a SUCCESS_COUNT=0
set /a FAILED_COUNT=0
set /a TOTAL_COUNT=0
set "DOWNLOAD_MODE=normal"
set "FORCE_OPT="

echo.
echo.
echo ============================================================
echo                       DOWNLOADING
echo ============================================================
echo.

for /f "usebackq delims=" %%U in ("!VALID_FILE!") do (
    set "CURRENT_URL=%%U"
    set /a TOTAL_COUNT+=1

    call :GET_INFO

    if not defined TITLE (
        echo.
        echo [FAIL] Could not retrieve the title.
        echo URL: !CURRENT_URL!
        >> "!FAILED_FILE!" echo(!CURRENT_URL!
        set /a FAILED_COUNT+=1
    ) else (
        echo.
        echo ------------------------------------------------------------
        echo [!TOTAL_COUNT!] !TITLE!
        echo ------------------------------------------------------------

        call :DOWNLOAD_ONE

        if errorlevel 1 (
            echo [FAIL] !TITLE!
            >> "!FAILED_FILE!" echo(!CURRENT_URL!
            set /a FAILED_COUNT+=1
        ) else (
            echo [OK] !TITLE!
            set /a SUCCESS_COUNT+=1
        )
    )
)

echo.
echo.
echo ============================================================
echo                     DOWNLOAD RESULTS
echo ============================================================
echo.
echo Successful : !SUCCESS_COUNT!
echo Failed     : !FAILED_COUNT!
echo Total      : !TOTAL_COUNT!
echo.
echo Download folder:
echo !OUTPUT_PATH!
echo.
echo ------------------------------------------------------------

goto POST_DOWNLOAD_MENU


rem ============================================================
rem DOWNLOAD ONE
rem ============================================================

:DOWNLOAD_ONE

set "FORCE_OPT="

if /i "!DOWNLOAD_MODE!"=="force" (
    set "FORCE_OPT=--force-overwrites"
)

if /i "!DOWNLOAD_MODE!"=="delete" (
    call :DELETE_EXISTING_CURRENT
)

if /i "!QUALITY!"=="wav" (
    if not exist "%APP_DIR%ffmpeg.exe" (
        echo.
        echo [ERROR] ffmpeg.exe could not be found.
        exit /b 1
    )

    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -x ^
        --audio-format wav ^
        --audio-quality 0 ^
        --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

if /i "!QUALITY!"=="original" (
    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

if /i "!QUALITY!"=="best" (
    if not exist "%APP_DIR%ffmpeg.exe" (
        echo.
        echo [ERROR] ffmpeg.exe could not be found.
        exit /b 1
    )

    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -x ^
        --audio-format mp3 ^
        --audio-quality 0 ^
        --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

if /i "!QUALITY!"=="320k" (
    if not exist "%APP_DIR%ffmpeg.exe" (
        echo.
        echo [ERROR] ffmpeg.exe could not be found.
        exit /b 1
    )

    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -x ^
        --audio-format mp3 ^
        --audio-quality 320K ^
        --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

if /i "!QUALITY!"=="256k" (
    if not exist "%APP_DIR%ffmpeg.exe" (
        echo.
        echo [ERROR] ffmpeg.exe could not be found.
        exit /b 1
    )

    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -x ^
        --audio-format mp3 ^
        --audio-quality 256K ^
        --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

if /i "!QUALITY!"=="192k" (
    if not exist "%APP_DIR%ffmpeg.exe" (
        echo.
        echo [ERROR] ffmpeg.exe could not be found.
        exit /b 1
    )

    yt-dlp.exe ^
        -f "bestaudio/best" ^
        !FORCE_OPT! ^
        -x ^
        --audio-format mp3 ^
        --audio-quality 192K ^
        --ffmpeg-location "%APP_DIR%ffmpeg.exe" ^
        -o "!OUTPUT_PATH!\%%(title)s.%%(ext)s" ^
        "!CURRENT_URL!"

    exit /b %ERRORLEVEL%
)

echo.
echo [ERROR] Unknown quality: !QUALITY!
exit /b 1


rem ============================================================
rem DELETE EXISTING
rem ============================================================

:DELETE_EXISTING_CURRENT

if not defined TITLE exit /b

if /i "!QUALITY!"=="wav" (
    del /q "!OUTPUT_PATH!\!TITLE!.wav" >nul 2>&1
) else if /i "!QUALITY!"=="original" (
    del /q "!OUTPUT_PATH!\!TITLE!.*" >nul 2>&1
) else (
    del /q "!OUTPUT_PATH!\!TITLE!.mp3" >nul 2>&1
)

exit /b


rem ============================================================
rem POST DOWNLOAD MENU
rem ============================================================

:POST_DOWNLOAD_MENU

echo.
echo ============================================================
echo                      REDOWNLOAD
echo ============================================================
echo.
if exist "!FAILED_FILE!" (
    findstr /r /c:"." "!FAILED_FILE!" >nul 2>&1
    if not errorlevel 1 (
        echo [1] Retry failed items only
    ) else (
        echo [1] Retry failed items only - no failed items
    )
) else (
    echo [1] Retry failed items only - no failed items
)
echo [2] Delete existing files and download all items again
echo [3] Download all items again without deleting existing files
echo [4] Return to main screen
echo.

set "RETRY_INPUT="
set /p "RETRY_INPUT=Select an option...: "

if /i "!RETRY_INPUT!"=="exit" goto MAIN
if /i "!RETRY_INPUT!"=="quit" goto MAIN
if "!RETRY_INPUT!"=="4" goto MAIN

if "!RETRY_INPUT!"=="1" goto RETRY_FAILED
if "!RETRY_INPUT!"=="2" goto REDOWNLOAD_DELETE
if "!RETRY_INPUT!"=="3" goto REDOWNLOAD_FORCE

echo.
echo [ERROR] Invalid selection.
goto POST_DOWNLOAD_MENU


:RETRY_FAILED
if not exist "!FAILED_FILE!" (
    echo.
    echo [INFO] There are no failed items.
    goto POST_DOWNLOAD_MENU
)

findstr /r /c:"." "!FAILED_FILE!" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [INFO] There are no failed items.
    goto POST_DOWNLOAD_MENU
)

copy /y "!FAILED_FILE!" "!VALID_FILE!" >nul
set "DOWNLOAD_MODE=normal"
goto EXECUTE_BATCH


:REDOWNLOAD_DELETE
set "DOWNLOAD_MODE=delete"
goto EXECUTE_BATCH


:REDOWNLOAD_FORCE
set "DOWNLOAD_MODE=force"
goto EXECUTE_BATCH


rem ============================================================
rem GET INFO
rem ============================================================

:GET_INFO

set "TITLE="
set "SOURCE_SIZE="

for /f "delims=" %%A in (
    'yt-dlp.exe --print "%%(title)s" --skip-download --no-warnings "!CURRENT_URL!" 2^>nul'
) do (
    set "TITLE=%%A"
)

for /f "delims=" %%A in (
    'yt-dlp.exe --print "%%(filesize_approx)s" --skip-download --no-warnings "!CURRENT_URL!" 2^>nul'
) do (
    set "SOURCE_SIZE=%%A"
)

exit /b


rem ============================================================
rem FORMAT SIZE
rem ============================================================

:FORMAT_SIZE

set "DISPLAY_SIZE=Unknown"

if not defined SOURCE_SIZE exit /b

for /f "delims=" %%S in (
    'powershell -NoProfile -Command "$b=[double]'%~1'; if($b -ge 1GB){'{0:N2} GB' -f ($b/1GB)} elseif($b -ge 1MB){'{0:N2} MB' -f ($b/1MB)} elseif($b -ge 1KB){'{0:N2} KB' -f ($b/1KB)} else {'{0:N0} B' -f $b}"'
) do (
    set "DISPLAY_SIZE=%%S"
)

exit /b


rem ============================================================
rem CALCULATE TOTAL SIZE
rem ============================================================

:CALCULATE_TOTAL_SIZE

set "TOTAL_SIZE=Unknown"

if not exist "!SIZE_FILE!" exit /b

for /f "delims=" %%T in (
    'powershell -NoProfile -Command "$n=0.0; Get-Content -LiteralPath $env:SIZE_FILE | ForEach-Object { $v=0.0; if([double]::TryParse($_,[ref]$v)){$n+=$v} }; if($n -ge 1GB){'{0:N2} GB' -f ($n/1GB)} elseif($n -ge 1MB){'{0:N2} MB' -f ($n/1MB)} elseif($n -ge 1KB){'{0:N2} KB' -f ($n/1KB)} else {'{0:N0} B' -f $n}"'
) do (
    set "TOTAL_SIZE=%%T"
)

exit /b


rem ============================================================
rem LOAD CONFIG
rem ============================================================

:LOAD_CONFIG

set "QUALITY="
set "OUTPUT="

for /f "usebackq tokens=1,* delims==" %%A in ("%APP_DIR%config.txt") do (
    if /i "%%A"=="quality" set "QUALITY=%%B"
    if /i "%%A"=="output" set "OUTPUT=%%B"
)

if not defined QUALITY set "QUALITY=best"
if not defined OUTPUT set "OUTPUT=Downloads"

exit /b


rem ============================================================
rem SAVE CONFIG
rem ============================================================

:SAVE_CONFIG

(
    echo # YouTube Audio Downloader Configuration
    echo quality=!QUALITY!
    echo output=!OUTPUT!
) > "%APP_DIR%config.txt"

exit /b


rem ============================================================
rem PREPARE OUTPUT
rem ============================================================

:PREPARE_OUTPUT

set "DEFAULT_OUTPUT=%APP_DIR%Downloads"

if not defined OUTPUT (
    set "OUTPUT=Downloads"
    set "OUTPUT_PATH=!DEFAULT_OUTPUT!"
    call :SAVE_CONFIG
    goto CREATE_OUTPUT
)

if /i "!OUTPUT!"=="Downloads" (
    set "OUTPUT_PATH=!DEFAULT_OUTPUT!"
    goto CREATE_OUTPUT
)

if "!OUTPUT:~1,1!"==":" (
    set "OUTPUT_PATH=!OUTPUT!"
    goto CHECK_OUTPUT
)

set "OUTPUT_PATH=%APP_DIR%!OUTPUT!"
goto CHECK_OUTPUT


:CHECK_OUTPUT

if exist "!OUTPUT_PATH!\." goto OUTPUT_OK

mkdir "!OUTPUT_PATH!" >nul 2>&1

if exist "!OUTPUT_PATH!\." goto OUTPUT_OK

echo.
echo [WARNING] The selected download folder could not be used.
echo [WARNING] Switching to the default Downloads folder.
echo.

set "OUTPUT=Downloads"
set "OUTPUT_PATH=!DEFAULT_OUTPUT!"

call :SAVE_CONFIG
goto CREATE_OUTPUT


:CREATE_OUTPUT

if not exist "!OUTPUT_PATH!\." (
    mkdir "!OUTPUT_PATH!" >nul 2>&1
)

if not exist "!OUTPUT_PATH!\." (
    echo.
    echo [ERROR] Could not create the default Downloads folder.
    echo [ERROR] Please check the permissions of the program folder.
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

if exist "!WORK_DIR!" rd /s /q "!WORK_DIR!" >nul 2>&1

endlocal
exit /b
```