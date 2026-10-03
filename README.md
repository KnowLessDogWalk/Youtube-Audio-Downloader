# YouTube Audio Downloader (v0.3 Beta)

# 한국어 가이드

Windows 환경을 위한 **YouTube 및 YouTube Music 오디오 다운로더**입니다.

터미널에서 간단하게 사용할 수 있으며, 상세한 설정이 가능한 대화형 모드와 빠르게 다운로드할 수 있는 자동 모드를 제공합니다.

---

## 주요 기능

- **두 가지 실행 모드**

  - `main.bat` — 설정, 검증, 다중 다운로드 등을 지원하는 대화형 모드
  - `fast.bat` — 별도의 확인 절차 없이 빠르게 다운로드하는 자동 모드

- **다양한 오디오 품질**

  - Original
  - MP3 — Best VBR
  - MP3 — 320 kbps
  - MP3 — 256 kbps
  - MP3 — 192 kbps
  - WAV

- **다중 다운로드**

  - 단일 URL
  - 여러 줄 URL 입력
  - 쉼표(`,`)로 구분된 여러 URL
  - 여러 항목을 한 번에 처리

- **다운로드 전 검증**

  - 영상 제목 자동 확인
  - 예상 파일 크기 확인
  - 유효하지 않은 링크 필터링
  - 다운로드 가능한 항목만 처리

- **스마트 재시도**

  - 다운로드 실패 항목 확인
  - 완료된 파일은 불필요하게 다시 다운로드하지 않음
  - 실패한 항목만 다시 다운로드 가능

- **자동 설정 및 복구**

  - `setup.bat`을 통한 필수 파일 확인
  - 프로그램 구성 상태 검사
  - 환경 및 파일 무결성 확인
  - 필요한 경우 자동 복구 지원

---

## 파일 및 폴더 구조

```text
YouTubeAudioDownloader/
├── setup.bat          # 프로그램 설정, 무결성 검사 및 자동 복구
├── main.bat           # 대화형 CLI (설정, 멀티 다운로드, 검증)
├── fast.bat           # 자동 CLI (WAV 고정, 무확인, 자동 재시도)
├── yt-dlp.exe         # 미디어 추출 엔진
├── ffmpeg.exe         # 오디오 변환 및 인코딩 엔진
├── config.txt         # 설정 파일 (자동 생성)
├── about.txt          # 프로그램 정보 및 제작자 정보 (자동 생성)
└── Downloads/         # 기본 다운로드 폴더 (자동 생성)
```

---

## 요구 사항

### 운영체제

- Windows 10 이상
- Windows Terminal 또는 명령 프롬프트

### 필수 구성 요소

프로그램은 다음 구성 요소를 사용합니다.

- **yt-dlp** — YouTube 등의 지원되는 플랫폼에서 미디어 스트림을 추출
- **FFmpeg** — 오디오 추출, 인코딩 및 형식 변환

필수 실행 파일은 배치 파일과 같은 폴더에 있어야 합니다.

```text
yt-dlp.exe
ffmpeg.exe
```

`setup.bat`을 실행하면 필요한 파일과 프로그램 환경을 확인할 수 있습니다.

---

## 설치 및 시작

### 1. 프로그램 다운로드

GitHub에서 프로젝트를 다운로드하거나 Clone합니다.

프로그램 폴더는 다음과 같은 형태여야 합니다.

```text
YouTubeAudioDownloader/
├── setup.bat
├── main.bat
├── fast.bat
├── yt-dlp.exe
└── ffmpeg.exe
```

### 2. Setup 실행

먼저 다음 파일을 실행합니다.

```text
setup.bat
```

`setup.bat`은 프로그램에 필요한 파일과 환경을 확인하고 필요한 설정을 준비합니다.

### 3. 프로그램 실행

설정이 완료되면 원하는 모드를 실행합니다.

```text
main.bat
```

또는

```text
fast.bat
```

별도의 설치 과정 없이 사용할 수 있도록 구성되어 있습니다.

---

## 사용 방법

### 대화형 모드 — `main.bat`

`main.bat`은 다운로드 전에 설정과 정보를 직접 확인하고 싶은 경우 사용하는 모드입니다.

```text
main.bat
```

을 실행한 뒤 YouTube 또는 YouTube Music URL을 입력합니다.

일반적인 과정은 다음과 같습니다.

```text
URL 입력
   ↓
URL 및 미디어 확인
   ↓
제목 / 예상 용량 표시
   ↓
다운로드 확인
   ↓
다운로드
   ↓
Downloads/ 저장
```

다운로드 전에 미디어 정보를 확인할 수 있기 때문에 여러 링크를 처리할 때도 유용합니다.

---

### 빠른 자동 모드 — `fast.bat`

`fast.bat`은 별도의 확인 과정 없이 빠르게 다운로드하고 싶은 경우 사용하는 모드입니다.

```text
fast.bat
```

을 실행한 뒤 URL을 입력하면 즉시 처리가 시작됩니다.

```text
URL 입력
   ↓
즉시 다운로드
   ↓
실패 시 자동 재시도
```

여러 URL을 한 번에 입력할 수도 있습니다.

> **참고:** `fast.bat`은 빠른 처리를 위해 미리 정해진 설정을 사용하며, `main.bat`의 전체 설정 기능과는 다릅니다.

---

## 여러 URL 입력

다음과 같은 방식으로 여러 URL을 입력할 수 있습니다.

### 단일 URL

```text
https://www.youtube.com/watch?v=XXXXXXXXXXX
```

### 쉼표로 구분

```text
https://www.youtube.com/watch?v=AAAAAAA,
https://www.youtube.com/watch?v=BBBBBBB,
https://www.youtube.com/watch?v=CCCCCCC
```

### 줄바꿈으로 입력

```text
https://www.youtube.com/watch?v=AAAAAAA
https://www.youtube.com/watch?v=BBBBBBB
https://www.youtube.com/watch?v=CCCCCCC
```

유효하지 않거나 접근할 수 없는 링크는 검증 과정에서 가능한 경우 자동으로 제외됩니다.

---

## 오디오 품질

`main.bat`에서는 다음과 같은 출력 옵션을 제공합니다.

| 옵션               | 설명                   |
| ---------------- | -------------------- |
| **Original**     | 가능한 경우 원본 오디오 형식을 유지 |
| **MP3 Best VBR** | 가변 비트레이트 방식으로 MP3 변환 |
| **MP3 320k**     | 320 kbps MP3         |
| **MP3 256k**     | 256 kbps MP3         |
| **MP3 192k**     | 192 kbps MP3         |
| **WAV**          | WAV 형식으로 변환          |

### Original과 변환 형식의 차이

**Original**은 가능한 경우 원본 오디오 스트림을 그대로 유지하는 방식입니다.

반면 MP3와 WAV는 FFmpeg를 이용해 오디오를 변환합니다.

> 손실 압축된 음원을 WAV로 변환하더라도 이미 손실된 음질이 복원되는 것은 아닙니다.

---

## 다운로드 전 검증

`main.bat`에서는 다운로드 전에 입력한 미디어의 정보를 확인할 수 있습니다.

검증 과정에서는 다음 항목을 확인합니다.

- URL 접근 가능 여부
- 미디어 제목
- 예상 파일 크기
- 유효하지 않은 URL
- 다운로드 가능한 항목

특히 여러 URL을 한 번에 처리할 때 잘못된 링크 때문에 전체 작업이 중단되는 것을 줄이는 데 도움이 됩니다.

---

## 스마트 재시도

여러 파일을 다운로드하는 과정에서 일부 항목이 실패하더라도 완료된 항목까지 다시 다운로드할 필요가 없도록 구성되어 있습니다.

기본적인 동작은 다음과 같습니다.

```text
다운로드 시작
   │
   ├── 성공 → 완료
   │
   └── 실패
        │
        ▼
      재시도
        │
        ├── 성공 → 완료
        └── 실패 → 실패 항목으로 유지
```

네트워크가 불안정하거나 일시적으로 미디어에 접근할 수 없는 경우 유용합니다.

---

## 설정

프로그램의 사용자 설정은 다음 파일에 저장됩니다.

```text
config.txt
```

설정에는 프로그램에서 사용하는 다음과 같은 항목이 저장될 수 있습니다.

- 다운로드 경로
- 오디오 형식

`config.txt`는 프로그램 실행 및 설정 과정에서 자동으로 생성 또는 업데이트됩니다.

설정 파일에 문제가 발생한 경우 `setup.bat`을 이용해 프로그램 환경을 다시 확인할 수 있습니다.

---

## 주요 명령어

`main.bat`에서는 다음 명령어를 사용할 수 있습니다.

| 명령어               | 설명                    |
| ----------------- | --------------------- |
| `set` / `setting` | 오디오 품질 및 다운로드 경로 설정   |
| `multi` / `mul`   | 멀티 다운로드 모드 진입         |
| `con` / `config`  | 현재 `config.txt` 설정 확인 |
| `abo` / `about`   | 프로그램 및 제작자 정보 확인      |
| `help` / `?`      | 사용 가능한 명령어 확인         |
| `exit` / `quit`   | 프로그램 종료 또는 이전 메뉴로 이동  |

---

## 문제 해결

### `yt-dlp.exe` 또는 `ffmpeg.exe`가 없다고 표시되는 경우

두 파일이 프로그램 폴더에 존재하는지 확인합니다.

```text
YouTubeAudioDownloader/
├── yt-dlp.exe
└── ffmpeg.exe
```

이후 다음 파일을 실행합니다.

```text
setup.bat
```

### URL 다운로드가 실패하는 경우

다음과 같은 원인이 있을 수 있습니다.

- 잘못된 URL
- 삭제되거나 비공개된 콘텐츠
- 네트워크 연결 문제
- 플랫폼 측의 일시적인 문제
- 현재 지원되지 않는 미디어

여러 파일을 다운로드하던 중 실패한 경우 재시도 기능을 이용할 수 있습니다.

### FFmpeg 관련 오류가 발생하는 경우

`ffmpeg.exe`가 배치 파일과 같은 폴더에 있는지 확인합니다.

```text
YouTubeAudioDownloader/
├── main.bat
├── fast.bat
├── ffmpeg.exe
└── yt-dlp.exe
```

### 설정이 이상하게 동작하는 경우

설정 변경 이후 문제가 발생했다면 다음 파일을 실행하여 프로그램 환경을 다시 확인합니다.

```text
setup.bat
```

---

##   빠른 시작

### 일반적인 사용

```text
1. setup.bat 실행
       ↓
2. main.bat 실행
       ↓
3. YouTube / YouTube Music URL 입력
       ↓
4. 미디어 정보 확인
       ↓
5. 다운로드 확인
       ↓
6. Downloads/에서 파일 확인
```

### 빠른 다운로드

```text
1. fast.bat 실행
       ↓
2. URL 입력
       ↓
3. Enter
       ↓
4. 자동 다운로드
```

---

##   참고 사항

- 인터넷 연결이 필요합니다.
- 다운로드 속도는 네트워크 환경과 해당 미디어의 상태에 따라 달라질 수 있습니다.
- `yt-dlp`와 `FFmpeg`는 각각 별도의 오픈소스 프로젝트이며 해당 프로젝트의 라이선스를 따릅니다.
- 플랫폼의 정책이나 기술적 변경에 따라 특정 URL 또는 기능이 정상적으로 작동하지 않을 수 있습니다.
- 현재 버전은 \*\*Beta (v0.3)\*\*이며 향후 기능과 동작 방식이 변경될 수 있습니다.

---

## Developer & Contact

**Developer:** KnowLessDogWalk
**GitHub:** [KnowLessDogWalk](https://github.com/KnowLessDogWalk?utm_source=chatgpt.com)
**Made by:** apple_pie

---

## License & Disclaimer

이 프로그램은 코드 작성, 디버깅 및 프로젝트 구조 설계를 위해 AI의 도움을 받아 개발되었습니다.

다운로드한 콘텐츠의 사용 및 배포에 대해서는 사용자가 해당 국가의 저작권법과 각 플랫폼의 이용약관을 준수할 책임이 있습니다.

저작권자의 허가 없이 콘텐츠를 무단으로 다운로드하거나 재배포하는 행위를 권장하지 않습니다.

본 프로그램은 책임감 있게 사용해 주세요.

---

## Version

**Current Version:** `v0.3 Beta`