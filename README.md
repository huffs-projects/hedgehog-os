#  Hedgehog OS

**A complete command-line only Arch Linux distribution with 90+ TUI applications**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux)](https://archlinux.org/)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/huffs-projects/hedgehog-os)

---

## Fully Terminal Distro

- **112 packages** (76 official + 36 AUR)
- **92+ TUI applications** fully configured
- **200+ themes** with base16-shell
- **Application launcher** with fuzzy search
- **Complete music setup** (ncmpcpp + mpd + cava)
- **Beautiful terminal** (Alacritty + tmux + custom status bar)
- **Modern CLI tools** (bat, eza, ripgrep, fd)
- **Zero GUI** - Pure terminal excellence

---

## Categories

### File Management
- `yazi` - File manager with preview
- `ncdu` - Disk usage analyzer
- `gtrash` - Safe delete (trash)

### System Monitoring
- `btop` - Modern system monitor with graphs
- `iotop` - Disk I/O monitoring
- `iftop` - Network bandwidth monitor
- `impala` - TUI process explorer

### Communication
- `gomuks` - Matrix/Element chat (bridges to WhatsApp, Telegram, Discord, Slack)
- `neomutt` - Email client (Gmail configured)
- `meshtastic` - Off-grid mesh networking

### Writing & Productivity
- `neovim` (LazyVim) - Advanced text editor
- `nb` - Note-taking with Git backing
- `jrnl` - Command-line journal
- `calcurse` - Calendar and scheduling
- `task` - Task manager (Taskwarrior)
- `glow` - Markdown preview
- `papis` - Reference manager
- `pandoc` - Document converter

### Research & Reference
- `wiki-tui` - Wikipedia browser
- `wikit` - Wikipedia quick lookup
- `lynx` / `w3m` - Web browsers
- `wordnet` - Dictionary/thesaurus

### Media
- `spotify-player` - Spotify TUI client
- `ncmpcpp` - Music player with visualizer
- `cmus` - Terminal music player
- `mpv` - Video player
- `cava` - Audio visualizer
- `pulsemixer` - Volume control

### Development
- `lazygit` - Git interface
- `lazydocker` - Docker management
- `navi` - Command cheatsheets

### And 50+ more tools...

---

## Features

### Application Launcher
Never memorize 90+ commands - just type:
```bash
apps
```
Fuzzy search through all applications by category!

### Global Theming
Change your entire system color scheme instantly:
```bash
base16_nord        # Nord theme
base16_monokai     # Monokai theme
base16_ocean       # Ocean theme
# 200+ themes available
```

### Smart Aliases
- `fm` → yazi (file manager)
- `monitor` → btop (system monitor)
- `fetch` → rxfetch (system info)
- `wiki` → wiki-tui (Wikipedia)
- `cat` → bat (syntax highlighting)
- `ls` → eza (modern ls)
- `grep` → ripgrep (faster grep)
- `find` → fd (modern find)

---

## Documentation

- [INSTALLATION.md](INSTALLATION.md) - Detailed installation guide
- [GITHUB-SETUP.md](GITHUB-SETUP.md) - How to deploy from GitHub
- [DEPLOY-NOW.md](DEPLOY-NOW.md) - Quick start guide

---

## Requirements

- **CPU:** x86_64 compatible
- **RAM:** 2 GB minimum, 4 GB recommended
- **Disk:** 20 GB minimum, 40 GB recommended
- **Internet:** Required (3-5 GB download)

---

## Manual Installation

If you prefer manual installation:

1. **Download config:**
   ```bash
   curl -O https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/archinstall-config.json
   ```

2. **Run archinstall:**
   ```bash
   archinstall --config archinstall-config.json
   ```

3. **After reboot, run post-install:**
   ```bash
   curl -O https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/post-install.sh
   sudo bash post-install.sh
   ```

---

### Auto-Configured
Every application is pre-configured with sensible defaults:
- **LazyVim** - Neovim with 40+ plugins pre-installed
- **Tmux** - Custom status bar with CPU/RAM/time
- **Alacritty** - Beautiful terminal with Catppuccin theme
- **ncmpcpp** - Music player with MPD configured
- **neomutt** - Gmail-ready email client
- **gomuks** - Matrix chat with E2E encryption

### Theme System (99%+ Coverage)
Three ways to create themes:
1. **Interactive** - `thememaker` (TUI color picker)
2. **Image-based** - `wal-theme image.jpg` (pywal)
3. **Built-in** - `base16_themename` (200+ themes)

Auto-synced apps (9):
- ncmpcpp, spotify-player, cmus (music)
- gomuks (chat)
- neomutt (email)
- calcurse (calendar)
- task (tasks)
- jq (JSON)
- nb/jrnl (notes via nvim)

---

## Quick Commands

### Application Management
```bash
apps              # Launch application browser
topgrade          # Update everything
```

### File Operations
```bash
fm                # File manager (yazi)
ncdu              # Disk usage
gtrash file       # Safe delete
```

### System Monitoring
```bash
monitor           # System monitor (btop)
iotop             # Disk I/O
iftop             # Network bandwidth
```

### Theming
```bash
theme             # Interactive theme creator
wal-theme pic.jpg # Theme from image
base16_nord       # Built-in theme
musictheme        # Sync all themed apps
```

### Writing & Productivity
```bash
nb add "note"     # Quick note
jrnl "entry"      # Journal entry
task add "todo"   # Add task
glow README.md    # Preview markdown
```

### Communication
```bash
gomuks            # Matrix chat
neomutt           # Email
wiki-tui          # Wikipedia
```

### Media
```bash
spotify-player    # Spotify TUI
ncmpcpp           # Music player
cava              # Visualizer
pulsemixer        # Volume control
```

---

## Advanced Features

### Meshtastic Integration
Off-grid mesh networking with LoRa radios:
```bash
meshtastic --help          # CLI interface
# Matrix bridge documentation included
```

### File Transfer
```bash
croc send file             # Encrypted P2P transfer
localsend send file        # Local network sharing
rsync -avz src/ dest/      # Advanced sync
```

### Development
```bash
lazygit                    # Git TUI
lazydocker                 # Docker TUI
navi                       # Command cheatsheets
```

### Research Tools
```bash
wikit "topic"              # Quick Wikipedia
wiki-tui                   # Wikipedia browser
wn word -synsn             # Dictionary/thesaurus
```

---

## Installation Details

### What Happens During Install

**Phase 1 - Base System (archinstall):**
- Minimal Arch base installation
- 76 official packages
- Systemd-boot bootloader
- NetworkManager configured
- User account created

**Phase 2 - Post-Install (automated):**
- Yay AUR helper installation
- 36 AUR packages installed
- LazyVim setup with plugins
- All configs generated
- Theme system installed
- Application launcher created
- Shell aliases configured

**Phase 3 - First Login:**
- rxfetch shows custom ASCII art
- All commands immediately available
- Type `apps` to explore everything

### Time Requirements
- Base install: 10-15 minutes
- Post-install: 15-25 minutes
- **Total: ~30 minutes** (depends on internet speed)

### Disk Usage
- Base system: ~3 GB
- After post-install: ~5-7 GB
- With user data/cache: ~10 GB typical

---

## Troubleshooting

### Installation Issues
```bash
# If archinstall fails
archinstall --config archinstall-config.json --dry-run

# If post-install fails
sudo bash post-install.sh 2>&1 | tee install.log
```

### Theme Issues
```bash
# Resync all themed apps
sync-music-themes

# Reset to default theme
base16_default-dark
```

### Service Issues
```bash
# Check service status
systemctl status NetworkManager
systemctl status bluetooth
systemctl --user status mpd

# Restart services
sudo systemctl restart NetworkManager
systemctl --user restart mpd
```

---

## Customization

### Adding Your Own Theme
1. Run `thememaker`
2. Pick 16 colors interactively
3. Apply immediately or save for later
4. Auto-syncs to all apps

### Modifying Configs
All configs are in standard locations:
- Neovim: `~/.config/nvim/`
- Alacritty: `~/.config/alacritty/alacritty.toml`
- Tmux: `~/.tmux.conf`
- Music: `~/.config/ncmpcpp/`, `~/.config/mpd/`
- Themes: `~/.config/base16-shell/`

### Adding More Apps
```bash
# Official repos
sudo pacman -S package-name

# AUR
yay -S package-name

# Update everything
topgrade
```

---

## Technical Specifications

### Base System
- **Distro:** Arch Linux (rolling release)
- **Kernel:** Linux (latest stable)
- **Init:** systemd
- **Bootloader:** systemd-boot
- **Shell:** Bash (zsh compatible)
- **Audio:** Pipewire

### Networking
- **Manager:** NetworkManager
- **Bluetooth:** BlueZ + bluetuith
- **VPN:** OpenVPN/WireGuard compatible
- **SSH:** OpenSSH server/client

### Development
- **Compilers:** GCC, base-devel
- **Languages:** Python, Node.js (via nvm), Rust (via rustup)
- **Containers:** Docker + docker-compose
- **Version Control:** Git + lazygit

---

## Credits & License

### Built With
- [Archinstall](https://github.com/archlinux/archinstall) - Official Arch installer
- [base16-shell](https://github.com/chriskempson/base16-shell) - Theme system
- [LazyVim](https://github.com/LazyVim/LazyVim) - Neovim distribution
- [Alacritty](https://github.com/alacritty/alacritty) - Terminal emulator

### License
MIT License - See project repository for details


---

**Hedgehog OS** - A complete terminal-based Arch Linux experience
