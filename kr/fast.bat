@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title YouTube Audio Downloader - Fast Auto Mode (WAV)

rem ============================================================
rem YouTube Audio Downloader - Fast Auto Mode
rem
rem 특징:
rem - WAV (무손실 오디오) 고정 다운로드
rem - Y/N 확인 없음
rem - 링크 입력 후 Enter 즉시 처리
rem - 한 줄에 여러 링크 입력 가능 (쉼표 구분)
rem - 제목 확인 실패 링크 자동 제외
rem - 실패 항목 최대 3회 자동 재시도
rem ============================================================


rem ============================================================
rem INITIALIZE
rem ============================================================

set "APP_DIR=%~dp0"
cd /d "%APP_DIR%"

set "WORK_DIR=%TEMP%\YouTubeAudioDownloader_Fast_%RANDOM%%RANDOM%"
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
    echo [ERROR] yt-dlp.exe를 찾을 수 없습니다.
    echo.
    echo 확인된 경로:
    echo %APP_DIR%yt-dlp.exe
    echo.
    echo yt-dlp.exe를 프로그램 폴더에 넣어주세요.
    echo ============================================================
    echo.
    pause
    goto EXIT
)

if not exist "%APP_DIR%ffmpeg.exe" (
    echo.
    echo ============================================================
    echo [ERROR] ffmpeg.exe를 찾을 수 없습니다.
    echo.
    echo 확인된 경로:
    echo %APP_DIR%ffmpeg.exe
    echo.
    echo ffmpeg.exe를 프로그램 폴더에 넣어주세요.
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
echo 오디오 포맷 : WAV (무손실 오디오)
echo 저장 위치   : !OUTPUT_PATH!
echo 입력 방식   : 링크 또는 쉼표(,) 구분 여러 링크
echo.
echo ※ Enter를 누르면 바로 다운로드합니다.
echo ※ 제목을 확인할 수 없는 링크는 자동 제외됩니다.
echo.
echo help 또는 ? = 도움말
echo.
echo ------------------------------------------------------------

set "INPUT="
set /p "INPUT=링크를 입력하세요...: "

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

rem 쉼표를 내부 구분자인 | 로 변환
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
echo                       링크 확인 중
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

    echo [SKIP] 제목을 확인할 수 없는 링크:
    echo        !CURRENT_URL!
)
)


rem ============================================================
rem NO VALID URL
rem ============================================================

if !VALID_COUNT! EQU 0 (

    echo.
    echo ------------------------------------------------------------
    echo [취소] 다운로드할 수 있는 링크가 없습니다.
    echo ------------------------------------------------------------
    goto MAIN
)


rem ============================================================
rem DOWNLOAD START
rem ============================================================

echo.
echo ------------------------------------------------------------
echo 유효한 링크 : !VALID_COUNT!개
echo.
echo 제외된 링크 : !INVALID_COUNT!개
echo.
echo 다운로드를 시작합니다.
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
echo                    다운로드 진행 중
echo ============================================================
echo.
echo 시도 : !ATTEMPT!/3
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

        echo [FAIL] 다운로드 실패
        >> "!FAILED_FILE!" echo(!CURRENT_URL!

        set /a FAILED_COUNT+=1

    ) else (

        echo [OK] 다운로드 성공

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
echo                    자동 재시도
echo ============================================================
echo.
echo 실패 : !FAILED_COUNT!개
echo.
echo 다음 시도에서 실패한 항목만 다시 다운로드합니다.
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
echo                    다운로드 완료
echo ============================================================
echo.
echo 성공 : !SUCCESS_COUNT!
echo 실패 : !FAILED_COUNT!
echo 시도 : !ATTEMPT!회
echo.
echo 저장 위치:
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
echo                 다운로드 결과
echo ============================================================
echo.
echo 최대 3회까지 자동 재시도했습니다.
echo.
echo 마지막 시도 성공 : !SUCCESS_COUNT!
echo 마지막 시도 실패 : !FAILED_COUNT!
echo.
echo 실패한 링크:
echo.

set /a FAIL_INDEX=0

for /f "usebackq delims=" %%U in ("!FAILED_FILE!") do (
    set /a FAIL_INDEX+=1
    echo [!FAIL_INDEX!] %%U
)

echo.
echo 저장 위치:
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
echo [사용 방법]
echo.
echo YouTube 또는 YouTube Music 링크를 입력하고
echo Enter를 누르면 바로 다운로드합니다.
echo.
echo ------------------------------------------------------------
echo.
echo [단일 링크]
echo.
echo https://www.youtube.com/watch?v=...
echo.
echo ------------------------------------------------------------
echo.
echo [여러 링크]
echo.
echo 여러 링크를 쉼표(,)로 구분해서 한 줄에 입력할 수 있습니다.
echo.
echo 예:
echo https://example.com/1,https://example.com/2
echo.
echo ------------------------------------------------------------
echo.
echo [링크 확인]
echo.
echo 다운로드 전에 각 링크의 제목을 확인합니다.
echo.
echo 제목을 확인할 수 없는 링크는
echo.
echo 다운로드 대상에서 제외됩니다.
echo.
echo ------------------------------------------------------------
echo.
echo [다운로드]
echo.
echo WAV (무손실 오디오) 포맷으로 자동 다운로드합니다.
echo 별도의 Y/N 확인 과정은 없습니다.
echo.
echo ------------------------------------------------------------
echo.
echo [자동 재시도]
echo.
echo 다운로드에 실패한 항목은 최대 3회까지
echo 자동으로 다시 시도합니다.
echo.
echo 성공한 항목은 다시 다운로드하지 않습니다.
echo.
echo ------------------------------------------------------------
echo.
echo [명령어]
echo.
echo help / ?
echo   도움말
echo.
echo exit / quit
echo   프로그램 종료
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
rem Downloads 예약값
rem ------------------------------------------------------------

if /i "!OUTPUT!"=="Downloads" (

    set "OUTPUT_PATH=!DEFAULT_OUTPUT!"

    goto CREATE_OUTPUT
)


rem ------------------------------------------------------------
rem 절대 경로
rem ------------------------------------------------------------

if "!OUTPUT:~1,1!"==":" (

    set "OUTPUT_PATH=!OUTPUT!"

    goto CHECK_OUTPUT
)


rem ------------------------------------------------------------
rem 상대 경로
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
rem 잘못된 경로 → Downloads fallback
rem ------------------------------------------------------------

echo.
echo [WARNING] 다운로드 위치를 사용할 수 없습니다.
echo [WARNING] 기본 Downloads 폴더로 변경합니다.
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
    echo [ERROR] 기본 Downloads 폴더를 생성할 수 없습니다.
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

if exist "!WORK_DIR!" (
    rd /s /q "!WORK_DIR!" >nul 2>&1
)

endlocal
exit /b