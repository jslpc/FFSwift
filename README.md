# FFSwift

FFSwift is a lightweight macOS GUI wrapper for FFmpeg written in SwiftUI, enabling users to leverage FFmpeg's powerful video and audio processing capabilities through a user-friendly interface. A very basic work in progress.

> [!WARNING]  
> FFSwift doesn't work as expected right now. This repo is for tracking overall progress, but basic functionality is not quite there after a whopping _4 hours_ of hard work. I don't know Swift, much of this was build through trial and error (and LLMs). **If you want to contribute, please submit a pull request.**

## Features

- [ ] Configure and execute FFmpeg commands with ease.
  - [ ] Make this bad boy run properly!
- [ ] Supports various video encoders, including x264 and x265 (including hardware acceleration with hevc_videotoolbox).
- [ ] Adjust parameters such as CRF, presets, tuning, and resolution scaling based on the encoder specified.
- [ ] Support for advanced filtering and HDR tone-mapping based on the detected MediaInfo.
- [ ] Maybe some other useful stuff eventually...

## License

FFSwift is licensed under the **GNU GPL v3** license.

This application serves as a GUI wrapper for FFmpeg, which is bundled into this app as a static binary, compiled specifically for Apple Silicon and found [here](https://osxexperts.net/). The creator(s) of FFSwift take no responsibility for any data that may become damaged through using this software.

FFmpeg is licensed under either **LGPL 2.1+** or **GPL 2.0+**, depending on your usage and configuration. Users are responsible for ensuring compliance with FFmpeg's licensing terms.

For more information on FFmpeg's license, please visit [FFmpeg Legal Information](https://www.ffmpeg.org/legal.html).

## Dependencies

FFSwift does not require FFmpeg to be installed on your system, as it is installed with FFSwift as a static binary. There shouldn't be any dependencies once this works.

The FFmpeg binary compiled with FFSwift is built for ARM architecture on Apple Silicon chips. This has not been tested on any other machine besides my MacBook Pro with M1 Pro CPU and may never work on Intel-based machines.
