# YouTube Audio Downloader (v0.3 Beta)

A lightweight, terminal-based YouTube and YouTube Music audio downloader designed for Windows. It provides both interactive batch control and automated fast execution.

## Quick Install

Run the following command to download and automatically run `setup.bat` in `Downloads/Youtube-Audio-Downloader`.

```cmd
cd /d "%USERPROFILE%\Downloads" && mkdir "Youtube-Audio-Downloader" 2>nul && cd "Youtube-Audio-Downloader" && curl -L -o setup.bat https://raw.githubusercontent.com/KnowLessDogWalk/Youtube-Audio-Downloader/en/setup.bat && setup.bat
```

---

## Key Features

- **Dual Execution Modes**: Comprehensive interactive management (`main.bat`) and one-click quick processing (`fast.bat`).
- **Audio Quality Options**: Supports Original, MP3 (Best VBR, 320k, 256k, 192k), and WAV formats.
- **Batch Processing**: Supports multi-line input and comma-separated URL parsing.
- **Pre-Download Verification**: Automatically checks video titles and estimated file sizes, filtering out invalid links before downloading.
- **Smart Retry System**: Easily retry failed items without re-downloading previously completed tracks.
- **Auto Healing & Setup**: `setup.bat` handles dependency checks, integrity validation, and environment maintenance.

---

## File & Folder Structure

```text
YouTubeAudioDownloader/
├── setup.bat          # System setup, integrity check, and auto-repair script
├── main.bat           # Interactive CLI script (Settings, Multi-download, Verification)
├── fast.bat           # Automated CLI script (Fixed WAV mode, No prompt, Auto-retry)
├── yt-dlp.exe         # Media extraction engine
├── ffmpeg.exe         # Audio encoding and conversion utility
├── config.txt         # Configuration file (Auto-generated)
├── about.txt          # Program details and author information (Auto-generated)
└── Downloads/         # Default download directory (Auto-generated)
```

---

## Requirements

### Operating System

- Windows 10 or later
- Windows Terminal or Command Prompt

### Included Dependencies

The downloader relies on the following components:

- **yt-dlp** — Used for extracting media streams from supported platforms.
- **FFmpeg** — Used for audio extraction, encoding, and format conversion.

The required executables should be located in the same directory as the batch scripts.

> `setup.bat` can be used to check the required files and repair the program environment when supported.

---

## Installation

### 1. Download the Project

Download or clone this repository to your Windows PC.

### 2. Run Setup

Run:

```text
setup.bat
```

The setup script checks the program environment and verifies required dependencies.

### 3. Start the Downloader

After setup is complete, choose one of the following:

```text
main.bat
```

for the interactive mode, or:

```text
fast.bat
```

for the automated mode.

No additional installation is required when all required executables are already included.

---

## Usage

### Interactive Mode — `main.bat`

`main.bat` is designed for users who want control over download settings and verification.

Run:

```text
main.bat
```

Then enter a YouTube or YouTube Music URL.

The program can:

1. Parse the entered URL.
2. Verify whether the URL is valid.
3. Retrieve basic media information.
4. Display the title and estimated size.
5. Apply the selected audio format and quality.
6. Ask for confirmation before downloading.
7. Save the completed file to the configured directory.

### Fast Auto Mode — `fast.bat`

`fast.bat` is intended for quick, repetitive downloads.

Run:

```text
fast.bat
```

Then enter one or more URLs.

The script processes the input immediately without the normal confirmation step and automatically retries failed downloads when possible.

> **Note:** `fast.bat` uses its predefined processing settings rather than the full interactive configuration flow.

---

## Multiple URL Input

The downloader supports several input formats.

### Single URL

```text
https://www.youtube.com/watch?v=XXXXXXXXXXX
```

### Multiple URLs — Comma Separated

```text
https://www.youtube.com/watch?v=AAAAAAA,
https://www.youtube.com/watch?v=BBBBBBB,
https://www.youtube.com/watch?v=CCCCCCC
```

### Multiple URLs — One Per Line

```text
https://www.youtube.com/watch?v=AAAAAAA
https://www.youtube.com/watch?v=BBBBBBB
https://www.youtube.com/watch?v=CCCCCCC
```

Invalid or unavailable links are filtered during the verification stage when possible.

---

## Audio Quality

`main.bat` provides several output options.

| Option           | Description                                                     |
| ---------------- | --------------------------------------------------------------- |
| **Original**     | Downloads the best available audio without forcing MP3 encoding |
| **MP3 Best VBR** | Converts audio to MP3 using variable bitrate encoding           |
| **MP3 320k**     | MP3 at 320 kbps                                                 |
| **MP3 256k**     | MP3 at 256 kbps                                                 |
| **MP3 192k**     | MP3 at 192 kbps                                                 |
| **WAV**          | Converts the source audio to WAV                                |

### Original vs. Converted Audio

**Original** is intended to preserve the source audio format whenever possible.

MP3 and WAV modes require FFmpeg to convert the downloaded audio.

> Converting a lossy source to WAV does **not** restore audio quality that was already lost in the original source.

---

## Download Verification

Before starting a download, `main.bat` can retrieve information about the requested media.

The verification process is used to:

- Check whether the URL is accessible.
- Retrieve the media title.
- Estimate the download size.
- Identify invalid or unavailable links.
- Prevent unnecessary download attempts.

This is particularly useful when processing multiple URLs at once.

---

## Smart Retry System

If multiple downloads are processed and some items fail, the downloader keeps track of unsuccessful items separately.

This allows failed downloads to be retried without unnecessarily downloading tracks that were already completed.

Typical workflow:

```text
Download
   │
   ├── Success → Completed
   │
   └── Failed
         │
         ▼
      Retry
         │
         ├── Success → Completed
         └── Failed → Remains in failed list
```

This is useful for unstable connections, temporarily unavailable media, or large batch downloads.

---

## Configuration

The downloader stores user settings in:

```text
config.txt
```

Depending on the selected configuration, this may include settings such as:

- Download directory
- Audio format

The configuration file is automatically created or updated by the program.

If the configuration becomes corrupted or needs to be regenerated, `setup.bat` can be used to restore the expected program environment.

---

## Main Commands

`main.bat` provides several commands for navigation and configuration.

| Command           | Description                                     |
| ----------------- | ----------------------------------------------- |
| `set` / `setting` | Change audio quality and download path          |
| `multi` / `mul`   | Enter multi-download mode                       |
| `con` / `config`  | Display the current `config.txt` settings       |
| `abo` / `about`   | Display program and developer information       |
| `help` / `?`      | Display available commands                      |
| `exit` / `quit`   | Exit the program or return to the previous menu |

---

## Troubleshooting

### `yt-dlp.exe` or `ffmpeg.exe` is missing

Make sure both files exist in the program directory:

```text
YouTubeAudioDownloader/
├── yt-dlp.exe
└── ffmpeg.exe
```

Then run:

```text
setup.bat
```

to check the installation.

### A URL fails to download

Possible causes include:

- Invalid or unavailable URL
- Private or restricted content
- Network connection problems
- Temporary platform-side changes
- Unsupported media

For batch downloads, use the retry function to attempt failed items again.

### FFmpeg-related errors

Make sure `ffmpeg.exe` is present in the same directory as the batch scripts.

```text
YouTubeAudioDownloader/
├── main.bat
├── fast.bat
├── ffmpeg.exe
└── yt-dlp.exe
```

### Configuration problems

If the program behaves unexpectedly after changing settings, run:

```text
setup.bat
```

and allow the program to perform its environment checks.

---

##   Quick Start

For the simplest workflow:

```text
1. Run setup.bat
       ↓
2. Run main.bat
       ↓
3. Paste a YouTube / YouTube Music URL
       ↓
4. Check the media information
       ↓
5. Confirm the download
       ↓
6. Find the result in Downloads/
```

For repeated downloads:

```text
1. Run fast.bat
       ↓
2. Paste one or multiple URLs
       ↓
3. Press Enter
       ↓
4. Downloads are processed automatically
```

---

##   Notes

- Internet access is required.
- Download speed depends on your network connection and the availability of the requested media.
- `yt-dlp` and `FFmpeg` are third-party components and are subject to their respective licenses.
- Platform behavior and supported URLs may change over time.
- This project is currently in **Beta (v0.3)**, so behavior and features may change in future releases.

---

## Developer & Contact

**Developer:** KnowLessDogWalk
**GitHub:** [KnowLessDogWalk](https://github.com/KnowLessDogWalk?utm_source=chatgpt.com)
**Made by:** apple_pie

---

## License & Disclaimer

This program was developed with AI assistance for coding, debugging, and project structuring.

This software is provided for personal and educational use. Users are responsible for complying with applicable copyright laws, platform Terms of Service, and any other relevant regulations when downloading or using content.

The developers do not encourage unauthorized downloading, redistribution, or copyright infringement.

Use the software responsibly and only download content that you are legally permitted to access or save.

---

## Version

**Current Version:** `v0.3 Beta`
