# PlanigaleOS

```
██████  ██       █████  ███    ██ ██  ██████   █████  ██      ███████
██   ██ ██      ██   ██ ████   ██ ██ ██       ██   ██ ██      ██
███████ ██      ███████ ██ ██  ██ ██ ██   ███ ███████ ██      █████
██      ██      ██   ██ ██  ██ ██ ██ ██    ██ ██   ██ ██      ██
██      ███████ ██   ██ ██   ████ ██  ██████  ██   ██ ███████ ███████

██████  ███████
██    ██ ██
██    ██ ███████
██    ██      ██
 ██████  ███████

┌─────────────────────────────────────────────────────────┐
│  A Complete Terminal-Only TUI Workstation Distro        │
│  83+ Packages • 30+ TUI Apps • Custom Config • Zero GUI │
└─────────────────────────────────────────────────────────┘
```

**TUI only distro for Raspberry Pi 3 A+**

PlanigaleOS is a lightweight Linux distribution optimized for people who can't be trusted with real computers or a desktop environment.

## Features

### Core Tools
- **Text Editors**: vim, nano, micro
- **File Management**: yazi
- **Terminal**: tmux, screen for session management
- **Theming**: Comprehensive theme system with 4 built-in themes

### Writing & Documentation
- **Markdown**: pandoc, glow, mdless
- **Spell Check**: aspell, hunspell
- **Documentation**: man pages, info

### Productivity Suite
- **Task Management**: todo.txt-cli, taskwarrior, timewarrior
- **Calendar**: calcurse
- **Notes**: jrnl, wiki
- **Accounting**: ledger

### Music & Audio
- **Music Player**: mpd, ncmpcpp
- **Audio Tools**: alsa-utils, pulseaudio-utils, sox
- **Codecs**: flac, lame, vorbis-tools

### System & Network
- **WiFi**: Impala (Beautiful WiFi TUI)
- **Monitoring**: htop, fastfetch, ncdu, iotop
- **Network**: nmap, mtr, bandwhich
- **Security**: gpg, pass, ssh-keygen

### Development
- **Version Control**: git, lazygit, tig, gh
- **Build Tools**: make, cmake, build-essential
- **Languages**: python3, nodejs, ruby, golang-go

### Text Processing
- **Search**: ripgrep, fd, fzf
- **Viewing**: bat, exa, tree
- **Data**: jq, yq, delta

## Requirements

- **Storage**: 8GB+ SD card
- **Build System**: Linux with build dependencies
- **Target**: Raspberry Pi 3 A+

## Themes
- **Dark**: Dark backgrounds with bright accents (default)
- **Light**: Light backgrounds with dark text
- **Monochrome**: Pure black and white minimal
- **Retro**: Classic green terminal aesthetic
- **Custom**: User-defined themes

## Quick Start

1. Clone this repository
2. Run `./build.sh` to create the distro image
3. Flash the generated image to an SD card
4. Boot your Raspberry Pi 3 A+


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
