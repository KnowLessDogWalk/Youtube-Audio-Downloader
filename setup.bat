@echo off
chcp 65001 >nul
title YouTube Audio Downloader - 무결성 검사 및 설치 (v0.3 Beta)
cls

echo ============================================================
echo  YouTube Audio Downloader (v0.3 Beta) - 자가 치유 시스템
echo ============================================================
echo.

set "RAW_BASE_URL=https://raw.githubusercontent.com/KnowLessDogWalk/Youtube-Audio-Downloader/kr"

:: -----------------------------------------------------------
:: [1/5] 네트워크 연결 상태 검사
:: -----------------------------------------------------------
echo [1/5] 네트워크 연결 상태를 확인하고 있습니다...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% neq 0 (
    echo [오류] 인터넷 연결이 올바르지 않습니다. 네트워크 상태를 확인한 후 다시 실행해 주세요.
    echo.
    pause
    exit /b
)
echo      - 인터넷 연결: 정상
echo.

:: -----------------------------------------------------------
:: [2/5] yt-dlp.exe 엔진 검사 및 최신화
:: -----------------------------------------------------------
echo [2/5] yt-dlp 다운로드 엔진을 검사 및 최신화하고 있습니다...
if not exist "yt-dlp.exe" (
    echo      - yt-dlp.exe 미존재 발견. 최신 빌드를 내려받습니다...
    curl -L -o "yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    if %errorlevel% neq 0 (
        echo [경고] yt-dlp.exe 다운로드에 실패했습니다.
    ) else (
        echo      - yt-dlp.exe 설치 완료.
    )
) else (
    echo      - yt-dlp.exe 존재 확인. 최신 업데이트를 진행합니다...
    yt-dlp.exe -U
)
echo.

:: -----------------------------------------------------------
:: [3/5] ffmpeg.exe 오디오 변환 엔진 검사
:: -----------------------------------------------------------
echo [3/5] ffmpeg 오디오 변환 엔진 존재 여부를 확인하고 있습니다...
if not exist "ffmpeg.exe" (
    echo      - ffmpeg.exe 미존재 발견. 공식 패키지를 다운로드합니다...
    curl -L -o "ffmpeg.zip" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    echo      - 압축을 해제하여 ffmpeg.exe를 추출합니다...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_temp' -Force"
    powershell -Command "Get-ChildItem -Path 'ffmpeg_temp' -Filter 'ffmpeg.exe' -Recurse | Copy-Item -Destination '.'"
    rmdir /s /q "ffmpeg_temp" >nul 2>&1
    del /f /q "ffmpeg.zip" >nul 2>&1
    if exist "ffmpeg.exe" (
        echo      - ffmpeg.exe 추출 및 설치 완료.
    ) else (
        echo [경고] ffmpeg.exe 추출 실패. 변환 기능이 제한될 수 있습니다.
    )
) else (
    echo      - ffmpeg.exe: 정상
)
echo.

:: -----------------------------------------------------------
:: [4/5] 메인 실행 스크립트 무결성 검사
:: -----------------------------------------------------------
echo [4/5] 메인 실행 스크립트(main.bat, fast.bat)의 무결성을 검사합니다...

if not exist "main.bat" (
    echo      - main.bat 손실됨 -> GitHub 원격 저장소에서 자동 복구 중...
    curl -s -L -o "main.bat" "%RAW_BASE_URL%/main.bat"
    if exist "main.bat" (
        echo      - main.bat 복구 완료.
    ) else (
        echo [오류] main.bat 복구 실패. 원격 저장소를 확인해 주세요.
    )
) else (
    echo      - main.bat: 정상
)

if not exist "fast.bat" (
    echo      - fast.bat 손실됨 -> GitHub 원격 저장소에서 자동 복구 중...
    curl -s -L -o "fast.bat" "%RAW_BASE_URL%/fast.bat"
    if exist "fast.bat" (
        echo      - fast.bat 복구 완료.
    ) else (
        echo [오류] fast.bat 복구 실패. 원격 저장소를 확인해 주세요.
    )
) else (
    echo      - fast.bat: 정상
)
echo.

:: -----------------------------------------------------------
:: [5/5] 설정 파일 및 Downloads 폴더 준비
:: -----------------------------------------------------------
echo [5/5] 설정 파일 및 Downloads 저장 폴더를 준비하고 있습니다...

if not exist "Downloads" (
    mkdir "Downloads"
    echo      - Downloads/ 저장 폴더 생성 완료.
) else (
    echo      - Downloads/ 저장 폴더: 준비됨
)

if not exist "config.txt" (
    (
        echo # YouTube Audio Downloader Configuration
        echo quality=wav
        echo output=Downloads
    ) > "config.txt"
    echo      - config.txt 기본 설정 파일 생성 완료.
) else (
    echo      - config.txt 설정 파일: 준비됨
)
echo.

echo ============================================================
echo  모든 무결성 검사 및 자가 치유 작업이 완료되었습니다!
echo  이제 main.bat 또는 fast.bat을 실행하여 사용하실 수 있습니다.
echo ============================================================
echo.
pause