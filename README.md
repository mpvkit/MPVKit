# MPVKit

[![mpv](https://img.shields.io/badge/mpv-$MPV_LATEST_VERSION-blue.svg)](https://github.com/mpv-player/mpv)
[![ffmpeg](https://img.shields.io/badge/ffmpeg-$FFMPEG_LATEST_VERSION-blue.svg)](https://github.com/FFmpeg/FFmpeg)
[![license](https://img.shields.io/github/license/mpvkit/MPVKit)](https://github.com/mpvkit/MPVKit/main/LICENSE)

> MPVKit is only suitable for learning `libmpv` and will not be maintained too frequently.

`MPVKit` is a collection of tools to use `mpv` in `iOS`, `macOS`, `tvOS` applications.

It includes scripts to build `mpv` native libraries.

Forked from [kingslay/FFmpegKit](https://github.com/kingslay/FFmpegKit)

## About Metal support

Metal support only a patch version ([#7857](https://github.com/mpv-player/mpv/pull/7857)) and does not officially support it yet. Encountering any issues is not strange. 

## Installation

### Swift Package Manager

```
https://github.com/mpvkit/MPVKit.git
```

## How to build

```bash
make build
# or specified platforms 
make build platform=ios,macos
# or build GPL version
make build enable-gpl
# or see help
make help
```

## Run default mpv player

```bash
./play.sh --input-commands='script-message display-stats-toggle' [url]
./play.sh --list-options
```

> Use <kbd>Shift</kbd>+<kbd>i</kbd> to show stats overlay

## License
Because MPVKit compiles FFmpeg and mpv with the GPL license enabled. So MPVKit follow the GPL license.
