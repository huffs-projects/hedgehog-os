# planigale-os
```
██████  ██       █████  ███    ██ ██  ██████   █████  ██      ███████     ⣿⡿⢟⣋⠉⠤⢄⣉⣉⣉⡉⣩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
██   ██ ██      ██   ██ ████   ██ ██ ██       ██   ██ ██      ██          ⡏⢠⣤⣴⣾⣿⣿⣿⣿⣿⣿⡿⠿⠿⠟⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
███████ ██      ███████ ██ ██  ██ ██ ██   ███ ███████ ██      █████       ⡇⠚⣛⡻⠿⣿⣿⣿⣿⣿⠟⣠⣤⣿⣿⣿⣿⣶⣌⡛⠿⠿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿
██      ██      ██   ██ ██  ██ ██ ██ ██    ██ ██   ██ ██      ██          ⣿⣷⣤⣬⣝⠪⣝⡻⠏⣡⣾⣿⣿⣿⣿⡿⣿⣿⣿⡅⠄⠔⣶⣤⣾⢘⣿⣿⣿⣿⣿⣿⣿
██      ███████ ██   ██ ██   ████ ██  ██████  ██   ██ ███████ ███████     ⣿⣿⣿⣿⣿⣿⣶⣭⣝⡛⠿⣿⣿⣿⣿⡇⣸⢿⣿⣢⣴⣿⠛⢿⣿⣌⣻⡿⣿⡿⣿⣿⣿
                                                                  ⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠰⣩⡛⠛⣛⠰⠁⣼⣿⡟⠻⢿⣦⣴⣿⣿⣦⣑⠢⣾⣿⣿⣿
██████  ███████                                                           ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣙⠛⠻⢿⣷⣮⣟⡟⠨⣔⣮⣭⣩⣴⣤⢰⢴⣾⣿⣿⣿
██    ██ ██                                                               ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣴⣿⣿⣿⣿⣦⡙⠻⢿⣿⣿⣿⣾⣷⣿⣿⣿⣿
██    ██ ███████                                                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿ 
██    ██      ██                                                   
 ██████  ███████                                                   

┌─────────────────────────────────────────────────────────┐
│  A Complete Terminal-Only TUI Workstation Distro        │
│  83+ Packages • 30+ TUI Apps • Custom Config • Zero GUI │
└─────────────────────────────────────────────────────────┘
```
**TUI only distro**

PlanigaleOS is a lightweight Linux distribution optimized for people who can't be trusted with real computers or a desktop enviroment.

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

- **Hardware**: Raspberry Pi 2 W (1GB RAM)
- **Storage**: 8GB+ SD card
- **Build System**: Linux with build dependencies

## Quick Start

### Prerequisites
```bash
# Install build dependencies
sudo apt update
sudo apt install -y build-essential git wget curl tar gzip bzip2 unzip \
    libncurses-dev flex bison gperf gettext texinfo help2man libtool \
    autotools pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libffi-dev liblzma-dev python3-dev python3-pip ruby-dev
```

### Build & Deploy
```bash
# Clone repository
git clone https://github.com/huffs-projects/planigale-os.git
cd planigale-os

# Install dependencies
make install-deps

# Build system
make build

# Deploy to SD card
sudo make deploy DEVICE=/dev/mmcblk0
```

## Architecture

```
planigale-os/
├── config/
│   ├── buildroot.config          # Buildroot configuration
│   └── packages.list             # Package definitions
├── packages/
│   ├── productivity.list         # Productivity tools
│   ├── writing.list              # Writing & documentation
│   ├── music.list                # Audio & music tools
│   ├── network.list              # Network utilities
│   ├── essential-text.list       # Text processing tools
│   ├── essential-utilities.list  # System utilities
│   └── additional-tools.list     # Additional tools
├── overlays/
│   ├── etc/                      # System configuration
│   └── home/planigale/           # User configuration
├── scripts/
│   ├── build.sh                  # Build script
│   ├── deploy.sh                 # Deployment script
│   ├── customize.sh              # System customization
│   ├── wifi-setup.sh             # WiFi configuration
│   └── install-deps.sh           # Dependency installer
└── Makefile                      # Build automation
```

## Package Categories

### Core System
- Buildroot-based minimal system
- ARM Cortex-A7 optimized kernel
- Essential system utilities

### TUI Applications
- Modern terminal-based tools
- Vim-like keybindings throughout
- Optimized for keyboard navigation

### Custom Configuration
- Pre-configured vim, tmux, bash
- Custom fastfetch with Planigale logo
- WiFi TUI setup scripts

## Themes
- **Dark**: Dark backgrounds with bright accents (default)
- **Light**: Light backgrounds with dark text
- **Monochrome**: Pure black and white minimal
- **Retro**: Classic green terminal aesthetic
- **Custom**: User-defined themes

## Contributing
Fork the repository. I will not be approving requests on ts.

## License

You can use whatever you want, I don't care (my code sucks(you don't want it))
