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
    echo [ERROR] yt-dlp.exe를 찾을 수 없습니다.
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
        echo 이 프로그램의 설명을 입력하세요.
    ) > "%APP_DIR%about.txt"
)

call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
echo ============================================================
echo                   YouTube Audio Downloader
echo ============================================================
echo.
echo 현재 퀄리티 : !QUALITY!
echo 저장 위치   : !OUTPUT_PATH!
echo.
echo help 또는 ? 를 입력하면 도움말을 볼 수 있습니다.
echo.
echo ------------------------------------------------------------

:MAIN
call :LOAD_CONFIG
call :PREPARE_OUTPUT

echo.
set "INPUT="
set /p "INPUT=링크 또는 명령어를 입력하세요...: "

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
echo 현재 퀄리티 : !QUALITY!
echo 저장 위치   : !OUTPUT_PATH!
echo.
echo [1] Change quality
echo [2] Change download folder
echo [B] Back
echo.

set "SETTING_INPUT="
set /p "SETTING_INPUT=선택하세요...: "

if /i "!SETTING_INPUT!"=="b" goto MAIN
if /i "!SETTING_INPUT!"=="exit" goto MAIN
if /i "!SETTING_INPUT!"=="quit" goto MAIN
if "!SETTING_INPUT!"=="1" goto CHANGE_QUALITY
if "!SETTING_INPUT!"=="2" goto CHANGE_OUTPUT

echo.
echo [ERROR] 올바른 선택이 아닙니다.
goto SETTING


rem ============================================================
rem CHANGE QUALITY
rem ============================================================

:CHANGE_QUALITY
echo.
echo ------------------------------------------------------------
echo 사용 가능한 퀄리티
echo.
echo [1] original = 원본 오디오 (변환 없음)
echo [2] best     = MP3 best quality (VBR)
echo [3] 320k     = MP3 320 kbps
echo [4] 256k     = MP3 256 kbps
echo [5] 192k     = MP3 192 kbps
echo [6] wav      = WAV 최고 품질 (DAW 권장)
echo.

set "NEW_QUALITY="
set /p "NEW_QUALITY=번호를 입력하세요...: "

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
echo [ERROR] 올바른 번호가 아닙니다.
goto CHANGE_QUALITY

:SAVE_QUALITY
set "QUALITY=!NEW_QUALITY!"
call :SAVE_CONFIG
call :LOAD_CONFIG

echo.
echo [OK] 퀄리티가 !QUALITY! 로 변경되었습니다.
echo [OK] config.txt가 업데이트되었습니다.
goto SETTING


rem ============================================================
rem CHANGE OUTPUT
rem ============================================================

:CHANGE_OUTPUT
echo.
echo ------------------------------------------------------------
echo 현재 다운로드 위치:
echo !OUTPUT_PATH!
echo.
echo 기본 Downloads 폴더:
echo %APP_DIR%Downloads
echo.
echo 저장할 폴더의 경로를 입력하세요.
echo.
echo 예:
echo C:\Users\사용자 이름\Downloads
echo D:\Music\YouTube
echo.
echo 큰따옴표가 있어도 됩니다.
echo 예: "C:\Users\사용자 이름\Downloads"
echo.
echo help 또는 ? = 경로 복사 가이드
echo exit 또는 quit = 메인 화면
echo.

set "NEW_OUTPUT="
set /p "NEW_OUTPUT=다운로드 위치를 입력하세요...: "

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
echo [OK] 다운로드 위치가 변경되었습니다.
echo [OK] 설정값: !OUTPUT!
echo [OK] 실제 경로: !OUTPUT_PATH!
echo [OK] config.txt가 업데이트되었습니다.
goto SETTING


:OUTPUT_HELP
echo.
echo.
echo ============================================================
echo                   다운로드 경로 도움말
echo ============================================================
echo.
echo Windows에서 폴더 경로를 복사하는 방법
echo.
echo 방법 1:
echo 1. 원하는 폴더를 파일 탐색기에서 엽니다.
echo 2. 상단 주소 표시줄을 클릭합니다.
echo 3. Ctrl + A 를 누릅니다.
echo 4. Ctrl + C 를 눌러 경로를 복사합니다.
echo 5. 이 창으로 돌아와 Ctrl + V 로 붙여넣습니다.
echo.
echo 방법 2:
echo 1. 원하는 폴더에서 Shift + 마우스 오른쪽 클릭
echo 2. "경로로 복사"를 선택합니다.
echo 3. 이 창에 Ctrl + V 로 붙여넣습니다.
echo.
echo 큰따옴표가 포함된 경로도 사용할 수 있습니다.
echo.
echo 예:
echo "C:\Users\사용자 이름\Downloads"
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
echo                         도움말
echo ============================================================
echo.
echo [명령어]
echo.
echo set / setting
echo   설정을 변경합니다.
echo.
echo con / config
echo   config.txt 내용을 표시합니다.
echo.
echo abo / about
echo   about.txt 내용을 표시합니다.
echo.
echo multi / mul
echo   여러 링크를 한꺼번에 입력합니다.
echo.
echo help / ?
echo   도움말을 표시합니다.
echo.
echo exit / quit
echo   메인 화면에서는 프로그램을 종료하고,
echo   하위 메뉴에서는 메인 화면으로 돌아갑니다.
echo.
echo ------------------------------------------------------------
echo.
echo [일반 다운로드]
echo.
echo YouTube 또는 YouTube Music 링크를 입력합니다.
echo 제목을 확인한 뒤 Y/N으로 다운로드 여부를 선택합니다.
echo.
echo 제목을 확인할 수 없으면 다운로드가 자동 취소됩니다.
echo.
echo ------------------------------------------------------------
echo.
echo [멀티 다운로드]
echo.
echo multi 또는 mul 을 입력하면 링크 입력 모드가 열립니다.
echo.
echo 여러 줄에 나눠서 입력할 수도 있습니다.
echo.
echo 입력을 끝내려면 dl 또는 download 를 입력합니다.
echo.
echo clear = 현재 입력한 링크 전부 삭제
echo help / ? = 멀티 다운로드 도움말
echo.
echo ------------------------------------------------------------
echo.
echo [멀티 다운로드 진행]
echo.
echo 다운로드 전 제목, 예상 용량, 총 예상 용량을 표시합니다.
echo Y를 입력하면 링크를 순서대로 하나씩 다운로드합니다.
echo.
echo ------------------------------------------------------------
echo.
echo [재다운로드]
echo.
echo 다운로드가 끝나면 다음 옵션을 사용할 수 있습니다.
echo.
echo [1] 실패한 항목만 다시 다운로드
echo [2] 모든 항목의 기존 파일을 삭제하고 다시 다운로드
echo [3] 기존 파일을 삭제하지 않고 다시 다운로드
echo [4] 메인 화면
echo.
echo ------------------------------------------------------------
echo.
echo [퀄리티]
echo.
echo original
echo   변환하지 않고 이용 가능한 원본 오디오 스트림을 저장합니다.
echo.
echo best
echo   MP3 최고 품질 VBR로 변환합니다.
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
echo   WAV 무손실 오디오 포맷으로 변환합니다 (DAW 권장).
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
echo                     링크 확인 중
echo ============================================================
echo.

set "TITLE="
set "SOURCE_SIZE="

call :GET_INFO

if not defined TITLE (
    echo.
    echo [취소]
    echo 제목을 확인할 수 없습니다.
    echo 다운로드를 취소합니다.
    echo.
    echo ------------------------------------------------------------
    goto MAIN
)

echo 제목       : !TITLE!
echo 퀄리티     : !QUALITY!
echo 저장 위치  : !OUTPUT_PATH!

if defined SOURCE_SIZE (
    call :FORMAT_SIZE "!SOURCE_SIZE!"
    echo 예상 용량 : !DISPLAY_SIZE!
)

echo.

if /i "!QUALITY!"=="wav" (
    echo "!TITLE!"을 "WAV 최고 품질"로 다운로드할까요? [Y/N]
) else if /i "!QUALITY!"=="original" (
    echo "!TITLE!"을 "원본 오디오"로 다운로드할까요? [Y/N]
) else if /i "!QUALITY!"=="best" (
    echo "!TITLE!"을 "MP3 best quality"로 다운로드할까요? [Y/N]
) else (
    echo "!TITLE!"을 "MP3 !QUALITY!"로 다운로드할까요? [Y/N]
)

echo.

set "CONFIRM="
set /p "CONFIRM=> "

if /i "!CONFIRM!"=="n" goto CANCEL_DOWNLOAD
if /i "!CONFIRM!"=="y" goto START_SINGLE_BATCH

echo.
echo [ERROR] Y 또는 N을 입력하세요.
goto SINGLE_DOWNLOAD


:START_SINGLE_BATCH
> "!VALID_FILE!" echo !CURRENT_URL!
goto EXECUTE_BATCH


:CANCEL_DOWNLOAD
echo.
echo [취소] 다운로드하지 않았습니다.
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
echo 링크를 입력하세요.
echo.
echo - 한 줄에 하나의 링크를 입력할 수 있습니다.
echo - 여러 링크를 한 번에 붙여넣을 수 있습니다.
echo - 여러 줄에 나눠서 입력할 수도 있습니다.
echo.
echo 입력을 끝내고 확인하려면 dl 또는 download 를 입력하세요.
echo clear = 입력한 링크 전부 삭제
echo help 또는 ? = 도움말
echo.
echo list = 현재 링크 목록
echo exit 또는 quit = 메인 화면
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
    echo [OK] 입력한 링크를 모두 삭제했습니다.
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
echo                     입력된 링크 목록
echo ============================================================
echo.

set "LIST_COUNT=0"

for /f "usebackq delims=" %%A in ("!QUEUE_FILE!") do (
    set /a LIST_COUNT+=1
    echo [!LIST_COUNT!] %%A
)

if "!LIST_COUNT!"=="0" (
    echo [INFO] 입력된 링크가 없습니다.
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
echo 링크 입력 예시:
echo.
echo https://example.com/1
echo https://example.com/2
echo.
echo 여러 줄로 나눠서 입력할 수 있습니다.
echo.
echo dl / download
echo   입력한 링크를 확인하고 다운로드를 시작합니다.
echo.
echo clear
echo   현재 입력한 링크를 모두 삭제합니다.
echo.
echo exit / quit
echo   메인 화면으로 돌아갑니다.
echo.
echo list
echo   현재 입력된 링크 목록을 표시합니다.
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
echo 제목과 예상 용량을 확인하고 있습니다...
echo.

for /f "usebackq delims=" %%U in ("!QUEUE_FILE!") do (
    set "CURRENT_URL=%%U"
    call :GET_INFO

    if defined TITLE (
        set /a ITEM_COUNT+=1
        set /a VALID_COUNT+=1

        call :FORMAT_SIZE "!SOURCE_SIZE!"

        echo [!ITEM_COUNT!] !TITLE!
        echo     용량: !DISPLAY_SIZE!
        echo.

        >> "!VALID_FILE!" echo(!CURRENT_URL!
        if defined SOURCE_SIZE >> "!SIZE_FILE!" echo !SOURCE_SIZE!
    ) else (
        echo [SKIP] 제목을 확인할 수 없는 링크:
        echo        !CURRENT_URL!
        echo        다운로드 목록에서 제외됩니다.
        echo.
    )
)

if !VALID_COUNT! EQU 0 (
    echo [취소] 다운로드할 수 있는 링크가 없습니다.
    echo.
    echo ------------------------------------------------------------
    goto MAIN
)

call :CALCULATE_TOTAL_SIZE

echo ------------------------------------------------------------
echo Total items : !VALID_COUNT!개
echo Total Estimated Size : !TOTAL_SIZE!
echo ------------------------------------------------------------
echo.
echo 위 목록을 순서대로 다운로드할까요? [Y/N]
echo.

set "CONFIRM="
set /p "CONFIRM=> "

if /i "!CONFIRM!"=="n" goto MAIN
if /i "!CONFIRM!"=="y" goto EXECUTE_BATCH

echo.
echo [ERROR] Y 또는 N을 입력하세요.
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
echo                       다운로드 중
echo ============================================================
echo.

for /f "usebackq delims=" %%U in ("!VALID_FILE!") do (
    set "CURRENT_URL=%%U"
    set /a TOTAL_COUNT+=1

    call :GET_INFO

    if not defined TITLE (
        echo.
        echo [FAIL] 제목을 확인할 수 없습니다.
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
echo                       다운로드 결과
echo ============================================================
echo.
echo 성공 : !SUCCESS_COUNT!
echo 실패 : !FAILED_COUNT!
echo 총   : !TOTAL_COUNT!
echo.
echo 저장 위치:
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
        echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
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
        echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
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
        echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
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
        echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
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
        echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
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
echo [ERROR] 알 수 없는 quality: !QUALITY!
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
echo                      다시 다운로드
echo ============================================================
echo.
if exist "!FAILED_FILE!" (
    findstr /r /c:"." "!FAILED_FILE!" >nul 2>&1
    if not errorlevel 1 (
        echo [1] 실패한 항목만 다시 다운로드
    ) else (
        echo [1] 실패한 항목만 다시 다운로드 - 실패 항목 없음
    )
) else (
    echo [1] 실패한 항목만 다시 다운로드 - 실패 항목 없음
)
echo [2] 모든 항목의 기존 파일을 삭제하고 다시 다운로드
echo [3] 기존 파일을 삭제하지 않고 다시 다운로드
echo [4] 메인 화면
echo.

set "RETRY_INPUT="
set /p "RETRY_INPUT=선택하세요...: "

if /i "!RETRY_INPUT!"=="exit" goto MAIN
if /i "!RETRY_INPUT!"=="quit" goto MAIN
if "!RETRY_INPUT!"=="4" goto MAIN

if "!RETRY_INPUT!"=="1" goto RETRY_FAILED
if "!RETRY_INPUT!"=="2" goto REDOWNLOAD_DELETE
if "!RETRY_INPUT!"=="3" goto REDOWNLOAD_FORCE

echo.
echo [ERROR] 올바른 번호가 아닙니다.
goto POST_DOWNLOAD_MENU


:RETRY_FAILED
if not exist "!FAILED_FILE!" (
    echo.
    echo [INFO] 실패한 항목이 없습니다.
    goto POST_DOWNLOAD_MENU
)

findstr /r /c:"." "!FAILED_FILE!" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [INFO] 실패한 항목이 없습니다.
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

set "DISPLAY_SIZE=알 수 없음"

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

set "TOTAL_SIZE=알 수 없음"

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
echo [WARNING] 다운로드 위치를 사용할 수 없습니다.
echo [WARNING] 기본 Downloads 폴더로 변경합니다.
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
    echo [ERROR] 기본 Downloads 폴더를 생성할 수 없습니다.
    echo [ERROR] 프로그램 폴더의 권한을 확인하세요.
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
echo 프로그램을 종료합니다.
echo.

if exist "!WORK_DIR!" rd /s /q "!WORK_DIR!" >nul 2>&1

endlocal
exit /b