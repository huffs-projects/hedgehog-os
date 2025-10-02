# Hedgehog OS - Installation Guide

Complete installation instructions with quick start and detailed options.

---

## Quick Start (Recommended)

### Two-Command Installation via GitHub

**Fastest method - No file downloads needed!**

**Step 1 - From Arch ISO (base install):**
```bash
curl -sL https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/install.sh | bash
```

**Step 2 - After reboot (post-install):**
```bash
curl -sL https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/post-install.sh | sudo bash
```

**Total time:** 30-60 minutes (depends on internet speed)

**Requirements:**
- Arch Linux ISO booted
- Internet connection
- GitHub repo set up (see [GITHUB-SETUP.md](GITHUB-SETUP.md))

---

## Prerequisites

### Hardware Requirements
- **CPU:** x86_64 compatible processor
- **RAM:** 2 GB minimum, 4 GB recommended
- **Disk:** 20 GB minimum, 40 GB recommended
- **Internet:** Required (3-5 GB download)

### Before Starting
1. **Download Arch ISO** from https://archlinux.org/download/
2. **Create bootable USB** with `dd`, Rufus, or Ventoy
3. **Backup data** - Installation will erase target disk
4. **Choose method:**
   - GitHub method (easiest, 2 commands)
   - Manual method (requires config files)

---

## Method 1: GitHub One-Command (Recommended)

### Step 1: Boot Arch ISO
1. Insert USB and boot from it
2. Select "Arch Linux install medium"
3. Wait for live environment

### Step 2: Connect to Internet

**Ethernet:** Works automatically

**WiFi:**
```bash
iwctl
station wlan0 connect YOUR_NETWORK
# Enter password
exit

# Test connection
ping -c 3 archlinux.org
```

### Step 3: Run Base Installation
```bash
curl -sL https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/install.sh | bash
```

**What happens:**
- Downloads `archinstall-config.json`
- Runs archinstall automatically
- Installs 76 official packages
- Configures bootloader, network, users
- Prompts for:
  - Disk selection
  - huffs-projects
  - Password
  - Timezone (defaults to America/New_York)

**Time:** 15-30 minutes

### Step 4: Reboot
The installer will prompt to reboot. Remove USB and login.

### Step 5: Run Post-Install
```bash
curl -sL https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/install.sh | sudo bash
```

**What happens:**
- Installs yay (AUR helper)
- Installs 36 AUR packages
- Configures LazyVim (Neovim)
- Sets up theme system (base16-shell, pywal)
- Generates all configs
- Creates application launcher
- Adds shell aliases

**Time:** 30-60 minutes

### Step 6: Final Reboot
```bash
sudo reboot
```

### Step 7: First Login
```bash
apps               # Launch app browser
base16_nord        # Set theme
btop               # System monitor
```

**Installation complete!**

---

## Method 2: Manual Installation

Use this if you can't use GitHub or prefer manual control.

### Step 1: Boot Arch ISO
Same as Method 1

### Step 2: Connect to Internet
Same as Method 1

### Step 3: Get Config File

**Option A: From USB**
```bash
# Mount USB
lsblk
mount /dev/sdX1 /mnt

# Copy file
cp /mnt/archinstall-config.json .

# Unmount
umount /mnt
```

**Option B: Download from web**
```bash
curl -O YOUR_URL/archinstall-config.json
# Or use wget
```

**Option C: Paste manually**
```bash
nano archinstall-config.json
# Paste content, Ctrl+O to save, Ctrl+X to exit
```

### Step 4: Run archinstall
```bash
archinstall --config archinstall-config.json
```

Prompts:
1. **Disk:** Choose target disk (WILL BE ERASED)
2. **huffs-projects:** Your user account name
3. **Password:** Your password
4. **Root password:** Leave blank (uses sudo)
5. **Timezone:** Defaults to America/New_York

### Step 5: Reboot
```bash
reboot
```

Remove USB and login with your credentials.

### Step 6: Get Post-Install Script

**Option A: From USB**
```bash
# Mount USB
lsblk
sudo mount /dev/sdX1 /mnt

# Copy script
cp /mnt/post-install.sh .

# Unmount
sudo umount /mnt
```

**Option B: Download**
```bash
curl -O YOUR_URL/post-install.sh
```

### Step 7: Run Post-Install
```bash
sudo bash post-install.sh
```

Wait for completion (30-60 minutes).

### Step 8: Final Reboot
```bash
sudo reboot
```

**Installation complete!**

---

## What Gets Installed

### Base System (archinstall)
- **76 Official Packages:**
  - Core: base, base-devel, linux, linux-firmware
  - Network: NetworkManager, bluez, openssh
  - Terminal: alacritty, tmux, neovim
  - System: btop, iotop, ncdu, smartmontools
  - Media: mpd, mpc, mpv, pipewire
  - Utilities: git, curl, wget, rsync, fzf
  - Tools: docker, gnupg, p7zip, dialog
  - And 50+ more...

- **4 System Services:**
  - NetworkManager (networking)
  - bluetooth (Bluetooth)
  - docker (containers)
  - mpd (music player daemon)

### Post-Install (AUR packages)
- **36 AUR Packages:**
  - File: yazi, gtrash
  - System: impala, rxfetch, topgrade
  - Dev: lazygit, lazydocker, navi
  - Writing: nb, jrnl, todotxt, papis
  - Media: spotify-player, ncmpcpp (configured), cava
  - Chat: gomuks, python-meshtastic
  - Artsy: pipes.sh, cbonsai, rain, mapscii, unimatrix, cxxmatrix, lavat
  - Tools: wikit, wiki-tui, wordnet-cli, libqalculate
  - Theme: python-pywal
  - Network: localsend-cli, bluetuith, outside
  - Time: peaclock, termdown
  - Text: viu, chafa, genact, termsaver

### Total: 112 packages (76 + 36)

---

## Installation Timeline

### Phase 1: Base System (15-30 min)
1. Download packages (10-20 min)
2. Install packages (3-5 min)
3. Configure bootloader (1-2 min)
4. Create user (1 min)

### Phase 2: Post-Install (30-60 min)
1. Install yay (2-3 min)
2. Download AUR packages (10-20 min)
3. Build AUR packages (15-30 min)
4. Clone LazyVim (1-2 min)
5. Generate configs (2-3 min)
6. Setup theme system (1-2 min)

### Phase 3: First Boot
- LazyVim auto-installs plugins (~2 min on first nvim launch)
- rxfetch shows custom ASCII art
- All 112 packages ready to use

**Total Time: ~45-90 minutes**

---

## Disk Usage

- **Base system:** ~3 GB
- **After post-install:** ~5-7 GB  
- **With caches/data:** ~10 GB typical
- **Recommended:** 40 GB for comfortable use

---

## Post-Installation Setup

### First Steps
```bash
# Explore applications
apps

# Set theme
base16_nord              # Or any of 200+ themes

# Update system
topgrade                 # Updates pacman, AUR, pip, cargo, etc.
```

### Configure Email (neomutt)
Edit `~/.config/neomutt/neomuttrc`:
```bash
nano ~/.config/neomutt/neomuttrc

# Replace:
# - YOUR_EMAIL@gmail.com
# - Your Name
# - YOUR_GMAIL_APP_PASSWORD

# Get app password: https://myaccount.google.com/apppasswords
```

### Configure Matrix Chat (gomuks)
```bash
gomuks
# On first run:
# 1. Enter homeserver: matrix.org (or your own)
# 2. Enter huffs-projects
# 3. Enter password
# 4. Setup E2E encryption (recommended)
```

### Setup Password Manager (pass)
```bash
# Generate GPG key
gpg --full-generate-key

# Initialize pass
pass init YOUR_GPG_ID

# Add first password
pass generate email/gmail
```

### Music Setup (ncmpcpp + mpd)
```bash
# Add music to ~/Music
cp /path/to/music ~/Music/

# Update MPD database
mpc update

# Launch player
ncmpcpp
```

---

## Troubleshooting

### Installation Fails

**Error: "No internet connection"**
```bash
# Test connection
ping -c 3 archlinux.org

# Reconnect WiFi
iwctl
station wlan0 connect YOUR_NETWORK
exit
```

**Error: "Disk not found"**
```bash
# List all disks
lsblk

# Ensure you selected correct disk in archinstall
```

**Error: "Package not found"**
```bash
# Update package database
pacman -Sy

# Retry installation
```

### Post-Install Fails

**Error: "yay installation failed"**
```bash
# Install manually
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

**Error: "AUR package build failed"**
```bash
# Skip failed package and continue
# Most failures are non-critical
# System will still be functional
```

**Error: "LazyVim clone failed"**
```bash
# Clone manually
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### Service Issues

**NetworkManager not working:**
```bash
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

**Bluetooth not working:**
```bash
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

**MPD not playing:**
```bash
systemctl --user enable mpd
systemctl --user start mpd
mpc update
```

### Theme Issues

**Theme not applying:**
```bash
# Re-source shell config
source ~/.bashrc

# Or manually load theme
base16_default-dark

# Sync themed apps
sync-music-themes
```

**Apps not themed:**
```bash
# Run sync script
sync-music-themes

# Restart affected applications
```

---

## Advanced Configuration

### Changing Default Settings

**Timezone:**
```bash
sudo timedatectl set-timezone America/Los_Angeles
# Or any from: timedatectl list-timezones
```

**Hostname:**
```bash
sudo hostnamectl set-hostname new-hostname
```

**Shell (to zsh):**
```bash
sudo pacman -S zsh
chsh -s /bin/zsh
# Logout and login
```

### Adding Custom Packages
```bash
# Official repos
sudo pacman -S package-name

# AUR
yay -S package-name

# Update everything
topgrade
```

### Customizing Configs
All configs are in standard XDG locations:
- **Neovim:** `~/.config/nvim/`
- **Alacritty:** `~/.config/alacritty/alacritty.toml`
- **Tmux:** `~/.tmux.conf`
- **Shell:** `~/.bashrc` or `~/.zshrc`
- **Themes:** `~/.config/base16-shell/`

### Creating Custom Themes
```bash
# Interactive TUI
thememaker

# From image
wal-theme ~/Pictures/wallpaper.jpg

# Manual (edit base16-shell script)
nano ~/.config/base16-shell/scripts/base16-mytheme.sh
```

---

## Verification

### Check Installation Success
```bash
# System info
fetch

# Package count
pacman -Q | wc -l          # Should be ~76 official
yay -Qm | wc -l            # Should be ~36 AUR

# Services
systemctl status NetworkManager bluetooth docker
systemctl --user status mpd

# Commands
apps --help
theme --help
```

### Test Key Features
```bash
# File manager
fm

# System monitor  
monitor

# Application launcher
apps

# Theme system
base16_nord

# Music player
ncmpcpp

# Chat
gomuks

# Email
neomutt
```

---

## Next Steps

1. **Explore apps:** Run `apps` and try different tools
2. **Set theme:** Choose from 200+ with `base16_themename`
3. **Configure email:** Edit neomutt config for Gmail
4. **Setup chat:** Login to Matrix with gomuks
5. **Add music:** Copy files to `~/Music` and run `mpc update`
6. **Read docs:** 
   - [README.md](README.md) - Complete features
   - [GITHUB-SETUP.md](GITHUB-SETUP.md) - Deploy your own

---

## Getting Help

### Built-in Help
```bash
# Application launcher
apps

# Command cheatsheets
navi

# Quick command help
tldr command-name

# Man pages
man command-name
```

### Resources
- **Arch Wiki:** https://wiki.archlinux.org/
- **AUR:** https://aur.archlinux.org/
- **Package search:** https://archlinux.org/packages/

### Common Commands
```bash
# Update everything
topgrade

# Search packages
pacman -Ss search-term     # Official
yay -Ss search-term        # AUR + Official

# Install package
sudo pacman -S package     # Official
yay -S package             # AUR

# Remove package
sudo pacman -R package

# Clean cache
sudo pacman -Sc
yay -Sc
```

---

**Installation complete! Enjoy your terminal-based Arch Linux system.**
