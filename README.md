# FrogOS

```
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ███████ ██████   ██████   ██████       ██████  ███████ 
⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⢠⣀⠀⠀⠀⠀⠀⠀⣀⡄⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀    ██      ██   ██ ██    ██ ██           ██    ██ ██      
⠀⠀⠀⠀⠀⠀⠀⣿⣿⡗⠀⣿⣿⣿⣶⣶⣾⣿⣿⠀⢾⣿⣿⠀⠀⠀⠀⠀⠀⠀    █████   ██████  ██    ██ ██   ███     ██    ██ ███████ 
⠀⠀⠀⠀⠀⠀⠀⠈⢉⣠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣧⣄⣉⠀⠀⠀⠀⠀⠀⠀⠀    ██      ██   ██ ██    ██ ██    ██     ██    ██      ██ 
⠀⠀⣀⣤⣤⣤⠀⢠⡿⠟⠛⢛⣋⣉⣉⣉⣉⣉⡛⠛⠻⠿⣦⠀⣤⣤⣤⣀⠀⠀    ██      ██   ██  ██████   ██████       ██████  ███████ 
⠀⢠⣿⣿⣿⣿⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣄⠀⢸⣿⣿⣿⡆⠀                                                       
⠀⠀⢿⣿⣿⣿⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣾⣿⣿⡿⠀⠀    ┌───────────────────────────────────────┐
⠀⠀⠈⢿⣿⡿⠀⣾⣟⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⣙⣿⡀⢹⣿⡿⠁⠀⠀    │ A Complete Terminal-Only NixOS Config │
⠀⠀⠀⠀⠹⣧⣌⠙⠻⣿⣦⡈⠻⣿⣿⣿⣿⡿⠁⣠⣾⡿⠋⣁⣴⠏⠀⠀⠀⠀    └───────────────────────────────────────┘
⠀⠀⠀⢀⣠⣬⣿⣿⣆⠈⣿⣷⡄⠹⣿⣿⡟⠀⣼⣿⠏⢠⣾⣿⣥⣄⡀⠀⠀⠀
⠀⠀⠚⠻⣿⣿⣿⣿⣿⠀⣿⣿⣷⡀⠛⠛⠁⣼⣿⣿⡀⢻⣿⣿⣿⣿⠟⠛⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⠁⠰⠿⣿⠿⠇⠀⠀⠠⠿⢿⠿⢧⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
```


**A NixOS Configuration designed for CM4 Lite (2GB RAM)**

FrogOS is a lightweight NixOS configuration optimized for people who can't be trusted with real computers or a desktop environment.

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
- **WiFi**: Impala
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

## Themes
- **Dark**: Dark backgrounds with bright accents (default)
- **Light**: Light backgrounds with dark text
- **Monochrome**: Pure black and white minimal
- **Retro**: Classic green terminal aesthetic
- **Custom**: User-defined themes
