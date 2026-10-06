@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title YouTube Audio Downloader - 무결성 검사 및 설치 (v0.3 Beta)
cls

echo ============================================================
echo  YouTube Audio Downloader (v0.3 Beta) - 자가 치유 시스템
echo ============================================================
echo.

set "RAW_BASE_URL=https://raw.githubusercontent.com/KnowLessDogWalk/Youtube-Audio-Downloader/kr"
set "SETUP_PATH=%~f0"
set "TEMP_DIR=%~dp0temp"

:: -----------------------------------------------------------
:: [1/6] 네트워크 연결 상태 검사
:: -----------------------------------------------------------
echo [1/6] 네트워크 연결 상태를 확인하고 있습니다...

ping -n 1 8.8.8.8 >nul 2>&1

if !errorlevel! neq 0 (
    echo [오류] 인터넷 연결이 올바르지 않습니다. 네트워크 상태를 확인한 후 다시 실행해 주세요.
    echo.
    pause
    exit /b
)

echo      - 인터넷 연결: 정상
echo.

:: -----------------------------------------------------------
:: [2/6] 임시 폴더 생성 및 setup.bat 무결성 검사
:: -----------------------------------------------------------
echo [2/6] setup.bat의 무결성을 검사하고 있습니다...

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
)

mkdir "%TEMP_DIR%" >nul 2>&1

if not exist "%TEMP_DIR%" (
    echo [오류] 임시 폴더 생성에 실패했습니다.
    echo.
    pause
    exit /b
)

echo      - 최신 setup.bat을 GitHub에서 임시로 다운로드합니다...

curl -sS -f -L -o "%TEMP_DIR%\setup.bat" "%RAW_BASE_URL%/setup.bat"

if !errorlevel! neq 0 (
    echo [경고] GitHub에서 최신 setup.bat을 다운로드하지 못했습니다.
    echo      - 현재 setup.bat을 그대로 사용합니다.
) else (
    call :GET_HASH "%SETUP_PATH%" CURRENT_SETUP_HASH
    call :GET_HASH "%TEMP_DIR%\setup.bat" REMOTE_SETUP_HASH

    if not defined CURRENT_SETUP_HASH (
        echo [오류] 현재 setup.bat의 SHA-256 계산에 실패했습니다.
        echo.
        call :CLEANUP
        pause
        exit /b
    )

    if not defined REMOTE_SETUP_HASH (
        echo [오류] GitHub setup.bat의 SHA-256 계산에 실패했습니다.
        echo.
        call :CLEANUP
        pause
        exit /b
    )

    echo      - 현재 setup.bat SHA-256: !CURRENT_SETUP_HASH!
    echo      - GitHub setup.bat SHA-256: !REMOTE_SETUP_HASH!

    if /I "!CURRENT_SETUP_HASH!"=="!REMOTE_SETUP_HASH!" (
        echo      - setup.bat 무결성: 정상
    ) else (
        echo      - setup.bat 무결성: 불일치
        echo      - 최신 setup.bat으로 자동 복구합니다...

        copy /Y "%TEMP_DIR%\setup.bat" "%SETUP_PATH%" >nul

        if !errorlevel! neq 0 (
            echo [오류] setup.bat 자동 복구에 실패했습니다.
            echo.
            call :CLEANUP
            pause
            exit /b
        )

        echo      - setup.bat 복구 완료.
        echo      - 최신 버전의 setup.bat을 다시 실행합니다...
        echo.

        call :CLEANUP

        start "" "%SETUP_PATH%"
        exit /b
    )
)

echo.

:: -----------------------------------------------------------
:: [3/6] yt-dlp.exe 엔진 검사 및 최신화
:: -----------------------------------------------------------
echo [3/6] yt-dlp 다운로드 엔진을 검사 및 최신화하고 있습니다...

if not exist "yt-dlp.exe" (
    echo      - yt-dlp.exe 미존재 발견. 최신 빌드를 내려받습니다...

    curl -f -L -o "yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

    if !errorlevel! neq 0 (
        echo [경고] yt-dlp.exe 다운로드에 실패했습니다.
    ) else (
        echo      - yt-dlp.exe 설치 완료.
    )
) else (
    echo      - yt-dlp.exe 존재 확인. 최신 업데이트를 진행합니다...

    yt-dlp.exe -U

    if !errorlevel! neq 0 (
        echo [경고] yt-dlp.exe 업데이트에 실패했습니다.
    ) else (
        echo      - yt-dlp.exe 업데이트 확인 완료.
    )
)

echo.

:: -----------------------------------------------------------
:: [4/6] ffmpeg.exe 오디오 변환 엔진 검사
:: -----------------------------------------------------------
echo [4/6] ffmpeg 오디오 변환 엔진 존재 여부를 확인하고 있습니다...

if not exist "ffmpeg.exe" (
    echo      - ffmpeg.exe 미존재 발견. 공식 패키지를 다운로드합니다...

    curl -f -L -o "ffmpeg.zip" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"

    if !errorlevel! neq 0 (
        echo [경고] ffmpeg 패키지 다운로드에 실패했습니다.
    ) else (
        echo      - 압축을 해제하여 ffmpeg.exe를 추출합니다...

        powershell -NoProfile -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_temp' -Force"

        if !errorlevel! neq 0 (
            echo [경고] ffmpeg 압축 해제에 실패했습니다.
        ) else (
            powershell -NoProfile -Command "Get-ChildItem -Path 'ffmpeg_temp' -Filter 'ffmpeg.exe' -Recurse | Select-Object -First 1 | Copy-Item -Destination '.' -Force"

            if exist "ffmpeg.exe" (
                echo      - ffmpeg.exe 추출 및 설치 완료.
            ) else (
                echo [경고] ffmpeg.exe 추출 실패. 변환 기능이 제한될 수 있습니다.
            )
        )

        rmdir /s /q "ffmpeg_temp" >nul 2>&1
        del /f /q "ffmpeg.zip" >nul 2>&1
    )
) else (
    echo      - ffmpeg.exe: 정상
)

echo.

:: -----------------------------------------------------------
:: [5/6] 프로그램 파일 임시 다운로드 및 무결성 검사
:: -----------------------------------------------------------
echo [5/6] 프로그램 파일의 무결성을 검사하고 있습니다...
echo.

call :VERIFY_FILE "main.bat" "main.bat"
call :VERIFY_FILE "fast.bat" "fast.bat"
call :VERIFY_FILE "about.txt" "about.txt"
call :VERIFY_FILE "README.md" "README.md"

echo.

:: -----------------------------------------------------------
:: [6/6] 설정 파일 및 Downloads 폴더 준비
:: -----------------------------------------------------------
echo [6/6] 설정 파일 및 Downloads 저장 폴더를 준비하고 있습니다...

if not exist "Downloads" (
    mkdir "Downloads"

    if !errorlevel! equ 0 (
        echo      - Downloads/ 저장 폴더 생성 완료.
    ) else (
        echo [경고] Downloads/ 저장 폴더 생성에 실패했습니다.
    )
) else (
    echo      - Downloads/ 저장 폴더: 준비됨
)

if not exist "config.txt" (
    (
        echo # YouTube Audio Downloader Configuration
        echo quality=wav
        echo output=Downloads
    ) > "config.txt"

    if !errorlevel! equ 0 (
        echo      - config.txt 기본 설정 파일 생성 완료.
    ) else (
        echo [경고] config.txt 생성에 실패했습니다.
    )
) else (
    echo      - config.txt 설정 파일: 준비됨
)

echo.

:: -----------------------------------------------------------
:: 임시 폴더 정리
:: -----------------------------------------------------------
echo      - 임시 파일을 정리하고 있습니다...

call :CLEANUP

if exist "%TEMP_DIR%" (
    echo [경고] temp 폴더 정리에 실패했습니다.
) else (
    echo      - temp 폴더 정리 완료.
)

echo.

echo ============================================================
echo  모든 무결성 검사 및 자가 치유 작업이 완료되었습니다!
echo  이제 main.bat 또는 fast.bat을 실행하여 사용하실 수 있습니다.
echo ============================================================
echo.
pause
exit /b


:: ============================================================
:: 함수
:: ============================================================

:: -----------------------------------------------------------
:: SHA-256 해시 계산
::
:: 사용법:
:: call :GET_HASH "파일경로" 결과변수명
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
:: GitHub 파일 다운로드 및 SHA-256 무결성 검사
::
:: 사용법:
:: call :VERIFY_FILE "로컬파일" "GitHub파일"
:: -----------------------------------------------------------
:VERIFY_FILE

set "LOCAL_FILE=%~1"
set "REMOTE_FILE=%~2"

echo      [%REMOTE_FILE%] 검사 중...

curl -sS -f -L -o "%TEMP_DIR%\%REMOTE_FILE%" "%RAW_BASE_URL%/%REMOTE_FILE%"

if !errorlevel! neq 0 (
    echo [오류] %REMOTE_FILE%을 GitHub에서 다운로드하지 못했습니다.
    echo.
    exit /b
)

if not exist "%TEMP_DIR%\%REMOTE_FILE%" (
    echo [오류] %REMOTE_FILE% 임시 파일이 생성되지 않았습니다.
    echo.
    exit /b
)

:: -----------------------------------------------------------
:: 로컬 파일이 없는 경우
:: -----------------------------------------------------------
if not exist "%LOCAL_FILE%" (
    echo      - %LOCAL_FILE% 손실됨 -^> GitHub 파일로 자동 복구 중...

    copy /Y "%TEMP_DIR%\%REMOTE_FILE%" "%LOCAL_FILE%" >nul

    if !errorlevel! neq 0 (
        echo [오류] %LOCAL_FILE% 복구 실패.
    ) else (
        echo      - %LOCAL_FILE% 복구 완료.
    )

    echo.
    exit /b
)

:: -----------------------------------------------------------
:: 로컬 / 원격 SHA-256 계산
:: -----------------------------------------------------------
call :GET_HASH "%LOCAL_FILE%" LOCAL_HASH
call :GET_HASH "%TEMP_DIR%\%REMOTE_FILE%" REMOTE_HASH

if not defined LOCAL_HASH (
    echo [오류] %LOCAL_FILE%의 SHA-256 계산에 실패했습니다.
    echo.
    exit /b
)

if not defined REMOTE_HASH (
    echo [오류] GitHub %REMOTE_FILE%의 SHA-256 계산에 실패했습니다.
    echo.
    exit /b
)

:: -----------------------------------------------------------
:: SHA-256 비교
:: -----------------------------------------------------------
if /I "!LOCAL_HASH!"=="!REMOTE_HASH!" (
    echo      - %LOCAL_FILE%: 정상
) else (
    echo      - %LOCAL_FILE% 무결성 불일치 -^> 최신 파일로 복구합니다...

    copy /Y "%TEMP_DIR%\%REMOTE_FILE%" "%LOCAL_FILE%" >nul

    if !errorlevel! neq 0 (
        echo [오류] %LOCAL_FILE% 복구 실패.
    ) else (
        echo      - %LOCAL_FILE% 복구 완료.
    )
)

echo.
exit /b


:: -----------------------------------------------------------
:: 임시 폴더 정리
:: -----------------------------------------------------------
:CLEANUP

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
)

exit /b
