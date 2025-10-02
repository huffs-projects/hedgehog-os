#!/bin/bash
# Post-install script for Arch TUI system setup
# This script installs yay (AUR helper), yazi, and sets up LazyVim

set -e

# Verify running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    echo "Usage: sudo bash post-install.sh"
    exit 1
fi

echo "========================================="
echo "Starting post-install setup..."
echo "========================================="

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~"$ACTUAL_USER")

# Verify user was detected
if [ -z "$ACTUAL_USER" ] || [ "$ACTUAL_USER" = "root" ]; then
    echo "ERROR: Could not detect non-root user"
    echo "Please run with: sudo -u username bash post-install.sh"
    exit 1
fi

echo "Detected user: $ACTUAL_USER"
echo "User home: $USER_HOME"

# Enable color and parallel downloads in pacman
echo "Configuring pacman..."
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

# Install yay (AUR helper)
echo "========================================="
echo "Installing yay (AUR helper)..."
echo "========================================="

# Ensure base-devel and git are installed
pacman -S --needed --noconfirm base-devel git

cd /tmp
rm -rf yay  # Clean any previous attempts
sudo -u "$ACTUAL_USER" git clone --depth 1 https://aur.archlinux.org/yay.git
cd yay
sudo -u "$ACTUAL_USER" makepkg -si --noconfirm
cd /tmp
rm -rf yay

# Verify yay installed
if ! command -v yay &> /dev/null; then
    echo "ERROR: yay installation failed"
    exit 1
fi

echo "yay installed successfully"

# Install yazi from AUR
echo "========================================="
echo "Installing yazi file manager..."
echo "========================================="

sudo -u "$ACTUAL_USER" yay -S --noconfirm --needed yazi

# Verify yazi installed
if ! command -v yazi &> /dev/null; then
    echo "WARNING: yazi installation may have failed"
fi

# Install additional useful packages from AUR
echo "========================================="
echo "Installing 36 AUR packages (yazi + 35 additional)..."
echo "========================================="

# Use --needed to skip already installed packages
sudo -u "$ACTUAL_USER" yay -S --noconfirm --needed \
    impala \
    lazygit \
    bluetuith \
    outside \
    spotify-player \
    gtrash \
    navi \
    lazydocker \
    nb \
    jrnl \
    todotxt \
    peaclock \
    termdown \
    papis \
    viu \
    pipes.sh \
    genact \
    cbonsai \
    rain \
    mapscii \
    unimatrix \
    termgraph \
    cxxmatrix \
    lavat \
    rxfetch \
    termsaver \
    gomuks \
    python-meshtastic \
    localsend-cli \
    wikit \
    wiki-tui \
    wordnet-cli \
    libqalculate \
    topgrade \
    python-pywal

# Set up LazyVim for neovim
echo "========================================="
echo "Setting up LazyVim..."
echo "========================================="

NVIM_CONFIG="$USER_HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ]; then
    echo "Backing up existing nvim config to $NVIM_CONFIG.backup"
    sudo -u "$ACTUAL_USER" mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup"
fi

sudo -u "$ACTUAL_USER" git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG"
sudo -u "$ACTUAL_USER" rm -rf "$NVIM_CONFIG/.git"

# Verify LazyVim cloned successfully
if [ ! -f "$NVIM_CONFIG/init.lua" ]; then
    echo "ERROR: LazyVim installation failed"
    exit 1
fi

# Set up vimwiki plugin
echo "Adding vimwiki plugin..."
sudo -u "$ACTUAL_USER" mkdir -p "$NVIM_CONFIG/lua/plugins"
sudo -u "$ACTUAL_USER" tee "$NVIM_CONFIG/lua/plugins/vimwiki.lua" > /dev/null <<'EOF'
return {
  {
    "vimwiki/vimwiki",
    event = "BufEnter *.md",
    keys = { "<leader>ww", "<leader>wt" },
    init = function()
      vim.g.vimwiki_list = {
        {
          path = "~/vimwiki",
          syntax = "markdown",
          ext = ".md",
        },
      }
      vim.g.vimwiki_global_ext = 0
    end,
  },
}
EOF

# Set up base16 plugin for Neovim
echo "Adding base16 colorscheme plugin..."
sudo -u "$ACTUAL_USER" tee "$NVIM_CONFIG/lua/plugins/base16.lua" > /dev/null <<'EOF'
return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Enable base16 colorscheme
      -- Automatically uses base16-shell theme if available
      vim.cmd("colorscheme base16-mocha")
    end,
  },
}
EOF

# Set up rxfetch with custom ASCII art
echo "========================================="
echo "Configuring rxfetch..."
echo "========================================="

RXFETCH_CONFIG="$USER_HOME/.config/rxfetch"
sudo -u "$ACTUAL_USER" mkdir -p "$RXFETCH_CONFIG"
sudo -u "$ACTUAL_USER" tee "$RXFETCH_CONFIG/custom.ascii" > /dev/null <<'EOF'

����
����
���������������
��������������������
��������������������������
����������������������������
�����������������������
��������������������������������������
����������������������������
��������������������
���������������������
����������������������
�����������

EOF

sudo -u "$ACTUAL_USER" tee "$RXFETCH_CONFIG/config.toml" > /dev/null <<'EOF'
# rxfetch configuration

# Use custom ASCII art
custom_ascii = "/home/USER/.config/rxfetch/custom.ascii"

# Color scheme (customize as needed)
color = "blue"

# Separator
separator = " ~> "

# Disable default logo
disable_logo = false

# Information to display
[info]
os = true
host = true
kernel = true
uptime = true
packages = true
shell = true
terminal = true
cpu = true
memory = true
EOF

# Replace USER with actual username in config
sed -i "s|/home/USER|$USER_HOME|g" "$RXFETCH_CONFIG/config.toml"

# Set up fastfetch configuration
echo "========================================="
echo "Configuring fastfetch..."
echo "========================================="

FASTFETCH_CONFIG="$USER_HOME/.config/fastfetch"
sudo -u "$ACTUAL_USER" mkdir -p "$FASTFETCH_CONFIG"

sudo -u "$ACTUAL_USER" tee "$FASTFETCH_CONFIG/config.jsonc" > /dev/null <<'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "~/.config/fastfetch/logo.txt",
    "padding": {
      "top": 1,
      "left": 2
    }
  },
  "display": {
    "separator": " ~> ",
    "color": "blue"
  },
  "modules": [
    {
      "type": "title",
      "format": "{user-name-colored}@{host-name-colored}"
    },
    "separator",
    {
      "type": "os",
      "key": "OS",
      "format": "{name} {arch}"
    },
    {
      "type": "kernel",
      "key": "Kernel"
    },
    {
      "type": "uptime",
      "key": "Uptime"
    },
    {
      "type": "packages",
      "key": "Packages"
    },
    {
      "type": "shell",
      "key": "Shell"
    },
    {
      "type": "terminal",
      "key": "Terminal"
    },
    {
      "type": "cpu",
      "key": "CPU"
    },
    {
      "type": "memory",
      "key": "Memory"
    },
    "separator",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
EOF

# Add custom ASCII art for fastfetch
sudo -u "$ACTUAL_USER" tee "$FASTFETCH_CONFIG/logo.txt" > /dev/null <<'EOF'

����
����
���������������
��������������������
��������������������������
����������������������������
�����������������������
��������������������������������������
����������������������������
��������������������
���������������������
����������������������
�����������


       HEDGEHOG OS - TUI Edition
EOF

echo "fastfetch configured with custom ASCII art"

# Set up base16-shell theming system
echo "========================================="
echo "Installing base16-shell theming system..."
echo "========================================="

BASE16_DIR="$USER_HOME/.config/base16-shell"
if [ ! -d "$BASE16_DIR" ]; then
    sudo -u "$ACTUAL_USER" git clone --depth 1 https://github.com/chriskempson/base16-shell.git "$BASE16_DIR"

    # Verify installation
    if [ ! -f "$BASE16_DIR/profile_helper.sh" ]; then
        echo "ERROR: base16-shell installation failed"
        exit 1
    fi
    echo "base16-shell installed with 200+ themes"
else
    echo "base16-shell already exists"
fi

# Set up Alacritty configuration
echo "========================================="
echo "Configuring Alacritty..."
echo "========================================="

ALACRITTY_CONFIG="$USER_HOME/.config/alacritty"
sudo -u "$ACTUAL_USER" mkdir -p "$ALACRITTY_CONFIG"
sudo -u "$ACTUAL_USER" tee "$ALACRITTY_CONFIG/alacritty.toml" > /dev/null <<'EOF'
# Alacritty Configuration
# Optimized for TUI applications and visual tools

[window]
# Window dimensions
dimensions = { columns = 120, lines = 30 }

# Window padding
padding = { x = 10, y = 10 }

# Window opacity
opacity = 0.95

# Decorations: "full", "none", "transparent", "buttonless"
decorations = "full"

# Startup mode: "Windowed", "Maximized", "Fullscreen"
startup_mode = "Windowed"

# Window title
title = "Alacritty"

# Allow terminal applications to change window title
dynamic_title = true

[scrolling]
# Maximum number of lines in the scrollback buffer
history = 10000

# Number of lines scrolled for every input scroll increment
multiplier = 3

[font]
# Font configuration
normal = { family = "monospace", style = "Regular" }
bold = { family = "monospace", style = "Bold" }
italic = { family = "monospace", style = "Italic" }
bold_italic = { family = "monospace", style = "Bold Italic" }

# Font size
size = 11.0

# Offset is the extra space around each character
offset = { x = 0, y = 0 }

# Glyph offset determines the locations of the glyphs within their cells
glyph_offset = { x = 0, y = 0 }

[colors]
# Use true color for better visuals with lolcat, cava, etc.
draw_bold_text_with_bright_colors = true

# Default colors
[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"

# Cursor colors
[colors.cursor]
text = "#1e1e2e"
cursor = "#f5e0dc"

# Selection colors
[colors.selection]
text = "CellForeground"
background = "#585b70"

# Normal colors
[colors.normal]
black = "#45475a"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#bac2de"

# Bright colors
[colors.bright]
black = "#585b70"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#a6adc8"

[bell]
# Visual bell animation
animation = "EaseOutExpo"
duration = 100
color = "#ffffff"

[selection]
# Characters that are used as separators for "semantic words"
semantic_escape_chars = ",`|:\"' ()[]{}<>\\t"

# When set to true, selected text will be copied to the primary clipboard
save_to_clipboard = true

[cursor]
# Cursor style
style = { shape = "Block", blinking = "On" }

# Cursor blink interval (milliseconds)
blink_interval = 750

# Cursor blink timeout (seconds)
blink_timeout = 5

# If true, the cursor will be rendered as a hollow box when unfocused
unfocused_hollow = true

# Thickness of the cursor (0.0 - 1.0)
thickness = 0.15

[mouse]
# Hide mouse cursor when typing
hide_when_typing = true

# URL launcher
[mouse.bindings]
binding = { mouse = "Right", mods = "Control" }
action = "PasteSelection"

[hints]
# URL launcher program
[[hints.enabled]]
regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\s{-}\\^�`]+"
command = "xdg-open"
post_processing = true
mouse = { enabled = true, mods = "None" }
binding = { key = "U", mods = "Control|Shift" }

[keyboard]
# Key bindings
bindings = [
    # Clipboard
    { key = "V", mods = "Control|Shift", action = "Paste" },
    { key = "C", mods = "Control|Shift", action = "Copy" },

    # Font size
    { key = "Plus", mods = "Control", action = "IncreaseFontSize" },
    { key = "Minus", mods = "Control", action = "DecreaseFontSize" },
    { key = "Key0", mods = "Control", action = "ResetFontSize" },

    # Scrolling
    { key = "PageUp", mods = "Shift", action = "ScrollPageUp" },
    { key = "PageDown", mods = "Shift", action = "ScrollPageDown" },
    { key = "Home", mods = "Shift", action = "ScrollToTop" },
    { key = "End", mods = "Shift", action = "ScrollToBottom" },

    # New window
    { key = "N", mods = "Control|Shift", action = "CreateNewWindow" },
]

[env]
# Environment variables
TERM = "alacritty"
EOF

echo "Alacritty configured with optimized settings for TUI applications"

# Set up btop config directory
echo "========================================="
echo "Setting up btop..."
echo "========================================="

BTOP_CONFIG="$USER_HOME/.config/btop"
sudo -u "$ACTUAL_USER" mkdir -p "$BTOP_CONFIG"

# Set up tmux configuration with status bar
echo "========================================="
echo "Configuring tmux with status bar..."
echo "========================================="

sudo -u "$ACTUAL_USER" tee "$USER_HOME/.tmux.conf" > /dev/null <<'EOF'
# Hedgehog OS - tmux Configuration
# Optimized for TUI applications with informative status bar

# ===== General Settings =====

# Enable mouse support
set -g mouse on

# Increase scrollback buffer
set -g history-limit 10000

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Enable true color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Enable focus events
set -g focus-events on

# Faster command sequences
set -s escape-time 0

# Display tmux messages for 4 seconds
set -g display-time 4000

# Refresh status bar every second
set -g status-interval 1

# ===== Key Bindings =====

# Remap prefix from Ctrl+B to Ctrl+A (easier to reach)
# Uncomment to change prefix:
# unbind C-b
# set -g prefix C-a
# bind C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Switch panes using Alt+arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Resize panes with Ctrl+arrow
bind -n C-Left resize-pane -L 2
bind -n C-Right resize-pane -R 2
bind -n C-Up resize-pane -U 2
bind -n C-Down resize-pane -D 2

# ===== Status Bar Styling =====

# Status bar position
set -g status-position bottom

# Status bar colors (base16-compatible)
set -g status-bg colour235
set -g status-fg colour137
set -g status-style dim

# ===== Left Status Bar =====

# Session name and info
set -g status-left-length 40
set -g status-left '#[fg=colour232,bg=colour154,bold] #{session_name} #[fg=colour154,bg=colour238] #[fg=colour250,bg=colour238] #(whoami) '

# ===== Right Status Bar =====

# System information
set -g status-right-length 100
set -g status-right '#[fg=colour238,bg=colour235]#[fg=colour250,bg=colour238] CPU: #(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk "{print 100 - \$1\"%\"}") #[fg=colour245,bg=colour238]#[fg=colour250] RAM: #(free -h | awk "/^Mem:/ {print \$3\"/\"\$2}") #[fg=colour241,bg=colour238]#[fg=colour233,bg=colour241] %Y-%m-%d #[fg=colour245,bg=colour241]#[fg=colour232,bg=colour245,bold] %H:%M:%S '

# ===== Window Status =====

# Window list position
set -g status-justify left

# Default window title colors
setw -g window-status-style fg=colour138,bg=colour235,none
setw -g window-status-format ' #I:#W#F '

# Active window title colors
setw -g window-status-current-style fg=colour232,bg=colour154,bold
setw -g window-status-current-format ' #I:#W#F '

# Window activity colors
setw -g window-status-activity-style fg=colour154,bg=colour235,none

# ===== Pane Styling =====

# Pane borders
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour154

# ===== Message Styling =====

# Message text colors
set -g message-style fg=colour232,bg=colour154,bold

# Command line colors
set -g message-command-style fg=colour154,bg=colour235

# ===== Additional Features =====

# Enable activity alerts
setw -g monitor-activity on
set -g visual-activity off

# Display pane numbers longer
set -g display-panes-time 2000

# Clock mode colors
setw -g clock-mode-colour colour154
setw -g clock-mode-style 24

# Copy mode colors
setw -g mode-style fg=colour232,bg=colour154,bold

# ===== Plugins (Optional) =====
# Uncomment to enable tmux plugin manager
# List of plugins
# set -g @plugin 'tmux-plugins/tpm'
# set -g @plugin 'tmux-plugins/tmux-sensible'
# set -g @plugin 'tmux-plugins/tmux-cpu'
# set -g @plugin 'tmux-plugins/tmux-battery'

# Initialize TMUX plugin manager (keep at bottom)
# run '~/.tmux/plugins/tpm/tpm'
EOF

echo "tmux configured with informative status bar"

# Create fzf-based application launcher
echo "========================================="
echo "Creating application launcher..."
echo "========================================="

sudo -u "$ACTUAL_USER" mkdir -p "$USER_HOME/.local/bin"

sudo -u "$ACTUAL_USER" tee "$USER_HOME/.local/bin/apps" > /dev/null <<'EOF'
#!/bin/bash
# Hedgehog OS - Application Launcher
# Uses fzf for quick app selection

apps="FILE MANAGEMENT
yazi|File manager with preview
ncdu|Disk usage analyzer

SYSTEM MONITORING
btop|Modern system monitor with graphs
iotop|Disk I/O monitoring
iftop|Network bandwidth monitor

TEXT EDITORS
nvim|Neovim with LazyVim
micro|Simple terminal editor
nano|Basic text editor

COMMUNICATION
gomuks|Matrix/Element chat (E2E encrypted)
irssi|IRC client
neomutt|Email client (Gmail configured)

WRITING & PRODUCTIVITY
nb|Note-taking with Git backing
jrnl|Command-line journal
calcurse|Calendar and scheduling
task|Task manager (Taskwarrior)
glow|Markdown preview
papis|Reference manager
pandoc|Document converter (use: pandoc file.md -o file.pdf)

RESEARCH
wiki-tui|Wikipedia browser
wikit|Wikipedia quick lookup (use: wikit \"topic\")
lynx|Web browser
w3m|Alternative web browser

MEDIA PLAYERS
spotify-player|Spotify TUI client
ncmpcpp|Music player with visualizer
cmus|Terminal music player
mpv|Video player
cava|Audio visualizer

VOLUME & AUDIO
pulsemixer|Volume control and audio mixer

DEVELOPMENT
lazygit|Git interface
lazydocker|Docker management
navi|Command cheatsheets

FILE TRANSFER
croc|Encrypted file transfer (use: croc send file)
localsend|Local network file sharing (use: localsend send file)

NETWORKING
nmtui|Network configuration
bluetuith|Bluetooth manager
outside|Weather information

UTILITIES
pass|Password manager
calcurse|Calendar
pulsemixer|Volume control
fastfetch|System information
rxfetch|Custom system fetch

TOOLS
qalc|Advanced calculator
bc|Basic calculator (use: bc -l)
wordnet|Dictionary/thesaurus (use: wn word -synsn)
zathura|PDF viewer
tldr|Quick command examples (use: tldr command)
ssh|Remote server access (use: ssh user@host)

THEME CREATORS
thememaker|Interactive theme builder (TUI)
wal-theme|Generate theme from images (pywal)
base16|List 200+ built-in themes

ARTSY & FUN
cxxmatrix|Matrix digital rain effect
pipes.sh|Animated pipes screensaver
cbonsai|Bonsai tree generator
rain|Rain animation
lavat|Lava lamp simulation
mapscii|World map in terminal
genact|Fake activity generator
termsaver|Terminal screensavers

THEMES
base16|List and preview themes (use: base16_themename)"

# Use fzf to select and run application
selected=$(echo "$apps" | grep -v "^[A-Z]" | grep -v "^$" | \
    fzf --height=80% \
        --reverse \
        --header="HEDGEHOG OS - APPLICATION LAUNCHER (ESC to quit)" \
        --prompt="Select app > " \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --border \
        --ansi \
        --color='header:italic:underline')

if [ -n "$selected" ]; then
    app=$(echo "$selected" | awk -F'|' '{print $1}')

    # Clear screen and run app
    clear

    # Special cases that need arguments or setup
    case $app in
        "wikit")
            read -p "Enter topic to search: " topic
            wikit "$topic" | bat
            read -p "Press Enter to continue..."
            ;;
        "pandoc")
            echo "Usage: pandoc input.md -o output.pdf"
            echo "Example formats: pdf, docx, epub, html"
            read -p "Press Enter to continue..."
            ;;
        "wordnet")
            read -p "Enter word to lookup: " word
            echo "Synonyms:"
            wn "$word" -synsn
            read -p "Press Enter to continue..."
            ;;
        "base16")
            echo "Available themes (type base16_themename):"
            ls ~/.config/base16-shell/scripts/ | sed 's/base16-/  /' | sed 's/.sh//'
            read -p "Press Enter to continue..."
            ;;
        "croc")
            read -p "File to send: " file
            croc send "$file"
            ;;
        "localsend")
            read -p "File to send: " file
            localsend send "$file"
            ;;
        "qalc")
            qalc
            ;;
        "bc")
            bc -l
            ;;
        *)
            $app
            ;;
    esac
fi
EOF

chmod +x "$USER_HOME/.local/bin/apps"

# Create Theme Maker (TUI theme builder)
echo "========================================="
echo "Installing Theme Maker..."
echo "========================================="

sudo -u "$ACTUAL_USER" tee "$USER_HOME/.local/bin/thememaker" > /dev/null << 'THEMEEOF'
#!/bin/bash
# Hedgehog OS - Interactive Theme Maker
# Create custom base16 themes with TUI interface

COLOR_PREVIEW=""
THEME_NAME=""
THEME_SLUG=""

# Color picker with preview
pick_color() {
    local color_name="$1"
    local default="$2"
    local color=""

    while true; do
        color=$(dialog --stdout --inputbox "Enter hex color for $color_name\n(format: RRGGBB or #RRGGBB)\n\nExamples:\n  FF0000 = red\n  00FF00 = green\n  0000FF = blue\n  FFFFFF = white\n  000000 = black" 15 60 "$default")

        if [ -z "$color" ]; then
            return 1
        fi

        # Remove # if present
        color="${color#\#}"

        # Validate hex
        if [[ "$color" =~ ^[0-9A-Fa-f]{6}$ ]]; then
            echo "$color"
            return 0
        else
            dialog --msgbox "Invalid hex color! Use format: RRGGBB\nExample: FF5733" 8 50
        fi
    done
}

# Main theme creation
create_theme() {
    # Get theme name
    THEME_NAME=$(dialog --stdout --inputbox "Enter theme name:" 8 50 "My Custom Theme")
    if [ -z "$THEME_NAME" ]; then
        exit 0
    fi

    # Create slug (lowercase, no spaces)
    THEME_SLUG=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

    dialog --msgbox "Theme Builder\n\nYou'll pick 16 colors:\n\n� 8 base colors (background, text, etc)\n� 8 accent colors (red, green, yellow, etc)\n\nTip: Start with background/foreground,\nthen choose accent colors that contrast well!" 14 60

    # Pick base colors
    base00=$(pick_color "Background (base00)" "1d1f21") || exit 0
    base01=$(pick_color "Lighter Background (base01)" "282a2e") || exit 0
    base02=$(pick_color "Selection Background (base02)" "373b41") || exit 0
    base03=$(pick_color "Comments (base03)" "969896") || exit 0
    base04=$(pick_color "Dark Foreground (base04)" "b4b7b4") || exit 0
    base05=$(pick_color "Foreground/Text (base05)" "c5c8c6") || exit 0
    base06=$(pick_color "Light Foreground (base06)" "e0e0e0") || exit 0
    base07=$(pick_color "Light Background (base07)" "ffffff") || exit 0

    # Pick accent colors
    base08=$(pick_color "Red/Error (base08)" "cc6666") || exit 0
    base09=$(pick_color "Orange (base09)" "de935f") || exit 0
    base0A=$(pick_color "Yellow (base0A)" "f0c674") || exit 0
    base0B=$(pick_color "Green (base0B)" "b5bd68") || exit 0
    base0C=$(pick_color "Cyan (base0C)" "8abeb7") || exit 0
    base0D=$(pick_color "Blue (base0D)" "81a2be") || exit 0
    base0E=$(pick_color "Magenta (base0E)" "b294bb") || exit 0
    base0F=$(pick_color "Brown (base0F)" "a3685a") || exit 0

    # Create base16 theme file
    BASE16_DIR="$HOME/.config/base16-shell/scripts"
    THEME_FILE="$BASE16_DIR/base16-$THEME_SLUG.sh"

    cat > "$THEME_FILE" << THEMEEND
#!/usr/bin/env bash
# base16-shell (https://github.com/chriskempson/base16-shell)
# Base16 Shell template by Chris Kempson (http://chriskempson.com)
# $THEME_NAME theme - created with Hedgehog OS Theme Maker

color00="$base00" # Base 00 - Black
color01="$base08" # Base 08 - Red
color02="$base0B" # Base 0B - Green
color03="$base0A" # Base 0A - Yellow
color04="$base0D" # Base 0D - Blue
color05="$base0E" # Base 0E - Magenta
color06="$base0C" # Base 0C - Cyan
color07="$base05" # Base 05 - White
color08="$base03" # Base 03 - Bright Black
color09="$base08" # Base 08 - Bright Red
color10="$base0B" # Base 0B - Bright Green
color11="$base0A" # Base 0A - Bright Yellow
color12="$base0D" # Base 0D - Bright Blue
color13="$base0E" # Base 0E - Bright Magenta
color14="$base0C" # Base 0C - Bright Cyan
color15="$base07" # Base 07 - Bright White
color16="$base09" # Base 09
color17="$base0F" # Base 0F
color18="$base01" # Base 01
color19="$base02" # Base 02
color20="$base04" # Base 04
color21="$base06" # Base 06
color_foreground="$base05" # Base 05
color_background="$base00" # Base 00

if [ -n "\$TMUX" ]; then
  # Tell tmux to pass the escape sequences through
  printf_template="\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\\\033\\\\"
  printf_template_var="\033Ptmux;\033\033]%d;rgb:%s\033\033\\\\\033\\\\"
  printf_template_custom="\033Ptmux;\033\033]%s%s\033\033\\\\\033\\\\"
elif [ "\${TERM%%[-.]*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  printf_template="\033P\033]4;%d;rgb:%s\007\033\\\\"
  printf_template_var="\033P\033]%d;rgb:%s\007\033\\\\"
  printf_template_custom="\033P\033]%s%s\007\033\\\\"
elif [ "\${TERM%%-*}" = "linux" ]; then
  printf_template="\033]P%x%s"
  printf_template_var="\033]P%x%s"
  printf_template_custom=""
else
  printf_template="\033]4;%d;rgb:%s\033\\\\"
  printf_template_var="\033]%d;rgb:%s\033\\\\"
  printf_template_custom="\033]%s%s\033\\\\"
fi

# 16 color space
printf "\$printf_template" 0  \$color00
printf "\$printf_template" 1  \$color01
printf "\$printf_template" 2  \$color02
printf "\$printf_template" 3  \$color03
printf "\$printf_template" 4  \$color04
printf "\$printf_template" 5  \$color05
printf "\$printf_template" 6  \$color06
printf "\$printf_template" 7  \$color07
printf "\$printf_template" 8  \$color08
printf "\$printf_template" 9  \$color09
printf "\$printf_template" 10 \$color10
printf "\$printf_template" 11 \$color11
printf "\$printf_template" 12 \$color12
printf "\$printf_template" 13 \$color13
printf "\$printf_template" 14 \$color14
printf "\$printf_template" 15 \$color15

# 256 color space
printf "\$printf_template" 16 \$color16
printf "\$printf_template" 17 \$color17
printf "\$printf_template" 18 \$color18
printf "\$printf_template" 19 \$color19
printf "\$printf_template" 20 \$color20
printf "\$printf_template" 21 \$color21

# foreground / background / cursor color
printf "\$printf_template_var" 10 \$color_foreground
printf "\$printf_template_var" 11 \$color_background
printf "\$printf_template_custom" 12 ";7"

# clean up
unset printf_template
unset printf_template_var
unset printf_template_custom
unset color00 color01 color02 color03 color04 color05 color06 color07
unset color08 color09 color10 color11 color12 color13 color14 color15
unset color16 color17 color18 color19 color20 color21
unset color_foreground color_background
THEMEEND

    chmod +x "$THEME_FILE"

    # Create preview
    dialog --msgbox "Theme Created!\n\nName: $THEME_NAME\nFile: base16-$THEME_SLUG\n\nApply now to see it?" 10 60

    if dialog --yesno "Apply theme '$THEME_NAME' now?" 7 50; then
        # Apply theme
        source "$THEME_FILE"

        # Save to shell configs for persistence
        for rc in ~/.bashrc ~/.zshrc; do
            if [ -f "$rc" ]; then
                # Remove old base16 theme line
                sed -i.bak '/^base16_/d' "$rc" 2>/dev/null
                # Add new theme
                echo "base16_$THEME_SLUG" >> "$rc"
            fi
        done

        # Sync music players
        if command -v sync-music-themes &> /dev/null; then
            sync-music-themes
        fi

        dialog --msgbox "Theme Applied!\n\nTo use this theme in the future:\n\n  base16_$THEME_SLUG\n\nIt will also load automatically on new shells!\n\nAll apps synced to match!" 14 60
    fi

    dialog --msgbox "Theme saved!\n\nYou can apply it anytime with:\n\n  base16_$THEME_SLUG\n\nFind it in the apps launcher or theme list!" 11 60
}

# Check for dialog
if ! command -v dialog &> /dev/null; then
    echo "Error: dialog not installed"
    echo "Install with: sudo pacman -S dialog"
    exit 1
fi

# Check for base16-shell
if [ ! -d "$HOME/.config/base16-shell" ]; then
    echo "Error: base16-shell not installed"
    echo "Run post-install.sh first"
    exit 1
fi

create_theme

clear
THEMEEOF

chmod +x "$USER_HOME/.local/bin/thememaker"

# Install pywal for automatic theme generation
echo "========================================="
echo "Installing Pywal (automatic theme generator)..."
echo "========================================="

# Pywal is already in the AUR package list above

# Create wal-apply script for easy pywal usage
sudo -u "$ACTUAL_USER" tee "$USER_HOME/.local/bin/wal-theme" > /dev/null << 'WALEOF'
#!/bin/bash
# Pywal Theme Generator - Generate themes from images

if ! command -v wal &> /dev/null; then
    echo "Error: pywal not installed"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Pywal - Automatic Theme Generator"
    echo ""
    echo "Usage:"
    echo "  wal-theme <image>          Generate theme from image"
    echo "  wal-theme -i <image>       Generate and preview"
    echo "  wal-theme --random         Random theme"
    echo "  wal-theme --theme <name>   Use built-in theme"
    echo ""
    echo "Examples:"
    echo "  wal-theme ~/Pictures/wallpaper.jpg"
    echo "  wal-theme --random ~/Pictures"
    echo "  wal-theme --theme nord"
    echo ""
    echo "Available themes:"
    wal --theme | tail -n +2
    exit 0
fi

# Generate theme
wal "$@"

# Reload terminal colors
source ~/.cache/wal/colors.sh

# Apply to tmux if running
if [ -n "$TMUX" ]; then
    tmux source-file ~/.tmux.conf 2>/dev/null
fi

# Sync music players
if command -v sync-music-themes &> /dev/null; then
    sync-music-themes
fi

echo ""
echo " Theme applied!"
echo "   Colors saved to: ~/.cache/wal/colors.sh"
echo "   All apps synced to match!"
echo ""
echo "To make permanent, add to your shell config:"
echo "  cat ~/.cache/wal/colors.sh >> ~/.bashrc"
WALEOF

chmod +x "$USER_HOME/.local/bin/wal-theme"

# Create music theme sync script
sudo -u "$ACTUAL_USER" tee "$USER_HOME/.local/bin/sync-music-themes" > /dev/null << 'SYNCEOF'
#!/bin/bash
# Sync music player themes with current base16/pywal theme

# Function to convert hex to RGB values
hex_to_rgb() {
    local hex=$1
    hex=${hex#\#}
    printf "%d %d %d" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

# Get current theme colors
if [ -f ~/.cache/wal/colors.sh ]; then
    # Pywal colors
    source ~/.cache/wal/colors.sh
    BASE00=$background
    BASE05=$foreground
    BASE08=$color1
    BASE0A=$color3
    BASE0B=$color2
    BASE0C=$color6
    BASE0D=$color4
    BASE0E=$color5
else
    # Try to get from current base16 theme
    CURRENT_THEME=$(grep "^base16_" ~/.bashrc 2>/dev/null | tail -1 | sed 's/base16_//')
    if [ -n "$CURRENT_THEME" ]; then
        THEME_FILE="$HOME/.config/base16-shell/scripts/base16-$CURRENT_THEME.sh"
        if [ -f "$THEME_FILE" ]; then
            # Extract colors from theme file
            BASE00=$(grep 'color00=' "$THEME_FILE" | cut -d'"' -f2)
            BASE05=$(grep 'color07=' "$THEME_FILE" | cut -d'"' -f2)
            BASE08=$(grep 'color01=' "$THEME_FILE" | cut -d'"' -f2)
            BASE0A=$(grep 'color03=' "$THEME_FILE" | cut -d'"' -f2)
            BASE0B=$(grep 'color02=' "$THEME_FILE" | cut -d'"' -f2)
            BASE0C=$(grep 'color06=' "$THEME_FILE" | cut -d'"' -f2)
            BASE0D=$(grep 'color04=' "$THEME_FILE" | cut -d'"' -f2)
            BASE0E=$(grep 'color05=' "$THEME_FILE" | cut -d'"' -f2)
        fi
    fi
fi

# Default colors if nothing found
BASE00=${BASE00:-"1d1f21"}
BASE05=${BASE05:-"c5c8c6"}
BASE08=${BASE08:-"cc6666"}
BASE0A=${BASE0A:-"f0c674"}
BASE0B=${BASE0B:-"b5bd68"}
BASE0C=${BASE0C:-"8abeb7"}
BASE0D=${BASE0D:-"81a2be"}
BASE0E=${BASE0E:-"b294bb"}

# Sync ncmpcpp
mkdir -p ~/.config/ncmpcpp
cat > ~/.config/ncmpcpp/config << NCMPCPP_EOF
# ncmpcpp config - Auto-synced with system theme

# Music directory
mpd_music_dir = "~/Music"

# Visualizer
visualizer_data_source = "/tmp/mpd.fifo"
visualizer_output_name = "FIFO Output for Visualizers"
visualizer_in_stereo = "yes"
visualizer_type = "spectrum"
visualizer_look = "�"
visualizer_color = cyan, blue, magenta

# Colors (synced with base16)
colors_enabled = "yes"
main_window_color = "white"
header_window_color = "cyan"
volume_color = "green"
state_line_color = "yellow"
state_flags_color = "red"
progressbar_color = "cyan"
progressbar_elapsed_color = "blue"
statusbar_color = "white"
alternative_ui_separator_color = "cyan"
window_border_color = "blue"
active_window_border = "magenta"

# Interface
user_interface = "alternative"
header_visibility = "yes"
statusbar_visibility = "yes"
titles_visibility = "yes"
enable_window_title = "yes"

# Playlist
playlist_display_mode = "columns"
browser_display_mode = "columns"
search_engine_display_mode = "columns"

# Progress bar
progressbar_look = ""
NCMPCPP_EOF

# Sync spotify-player
mkdir -p ~/.config/spotify-player
cat > ~/.config/spotify-player/theme.toml << SPOTIFY_EOF
# Spotify Player Theme - Auto-synced with system theme

[themes.custom]
name = "Hedgehog Theme"

[themes.custom.palette]
background = "#$BASE00"
foreground = "#$BASE05"
black = "#$BASE00"
red = "#$BASE08"
green = "#$BASE0B"
yellow = "#$BASE0A"
blue = "#$BASE0D"
magenta = "#$BASE0E"
cyan = "#$BASE0C"
white = "#$BASE05"
bright_black = "#$BASE00"
bright_red = "#$BASE08"
bright_green = "#$BASE0B"
bright_yellow = "#$BASE0A"
bright_blue = "#$BASE0D"
bright_magenta = "#$BASE0E"
bright_cyan = "#$BASE0C"
bright_white = "#$BASE05"
SPOTIFY_EOF

# Add theme selection to config if not present
if [ ! -f ~/.config/spotify-player/app.toml ]; then
    cat > ~/.config/spotify-player/app.toml << SPOTIFY_APP_EOF
theme = "custom"
SPOTIFY_APP_EOF
fi

# Sync cmus
mkdir -p ~/.config/cmus
cat > ~/.config/cmus/hedgehog.theme << CMUS_EOF
# cmus theme - Auto-synced with system theme
set color_win_bg=default
set color_win_fg=$BASE05
set color_titlewin_bg=default
set color_titlewin_fg=$BASE0D
set color_statusline_bg=default
set color_statusline_fg=$BASE05
set color_win_cur=$BASE0A
set color_win_cur_sel_bg=$BASE0D
set color_win_cur_sel_fg=$BASE00
set color_win_sel_bg=$BASE0C
set color_win_sel_fg=$BASE00
set color_win_title_bg=default
set color_win_title_fg=$BASE0E
set color_cmdline_bg=default
set color_cmdline_fg=$BASE05
set color_error=$BASE08
set color_info=$BASE0B
CMUS_EOF

# Sync gomuks (Matrix chat)
mkdir -p ~/.config/gomuks
if [ ! -f ~/.config/gomuks/config.yaml ]; then
    # Create basic config if it doesn't exist
    cat > ~/.config/gomuks/config.yaml << GOMUKS_INIT
# gomuks config - Auto-generated
homeserver: https://matrix.org
GOMUKS_INIT
fi

# Update or add theme section
if grep -q "^preferences:" ~/.config/gomuks/config.yaml 2>/dev/null; then
    # Preferences section exists, update it
    sed -i.bak '/^preferences:/,/^[^ ]/ {
        /^  theme:/d
        /^preferences:/a\
  theme: hedgehog
    }' ~/.config/gomuks/config.yaml 2>/dev/null
else
    # Add preferences section
    cat >> ~/.config/gomuks/config.yaml << GOMUKS_PREF

preferences:
  theme: hedgehog
GOMUKS_PREF
fi

# Create custom theme
mkdir -p ~/.config/gomuks/themes
cat > ~/.config/gomuks/themes/hedgehog.yaml << GOMUKS_THEME
# gomuks Hedgehog Theme - Auto-synced with system theme
---
main:
  text: '#$BASE05'
  background: '#$BASE00'
  subtext: '#$BASE03'

sidebar:
  text: '#$BASE05'
  background: '#$BASE00'
  title: '#$BASE0D'

rooms:
  list:
    selected: '#$BASE0D'
    unselected: '#$BASE05'
    has-activity: '#$BASE0B'
    has-mention: '#$BASE08'

message:
  sender: '#$BASE0E'
  timestamp: '#$BASE03'
  text: '#$BASE05'

  # Message types
  error: '#$BASE08'
  warning: '#$BASE0A'
  info: '#$BASE0C'
  debug: '#$BASE03'

input:
  text: '#$BASE05'
  background: '#$BASE00'
  placeholder: '#$BASE03'

buttons:
  primary: '#$BASE0D'
  destructive: '#$BASE08'
  success: '#$BASE0B'

borders:
  focused: '#$BASE0E'
  blurred: '#$BASE03'
GOMUKS_THEME

# Sync neomutt (Email client)
mkdir -p ~/.config/neomutt
cat > ~/.config/neomutt/colors << NEOMUTT_EOF
# neomutt colors - Auto-synced with system theme

# Basic colors
color normal     color$BASE05 color$BASE00  # Normal text
color indicator  color$BASE00 color$BASE0D  # Selected message (blue bg)
color status     color$BASE05 color$BASE00  # Status bar
color tree       color$BASE0C color$BASE00  # Thread tree (cyan)
color error      color$BASE08 color$BASE00  # Errors (red)
color message    color$BASE0B color$BASE00  # Info messages (green)
color markers    color$BASE0A color$BASE00  # Wrapped line markers (yellow)

# Message index colors
color index      color$BASE05 color$BASE00 ~A  # All messages
color index      color$BASE0B color$BASE00 ~N  # New messages (green)
color index      color$BASE0D color$BASE00 ~O  # Old messages (blue)
color index      color$BASE0A color$BASE00 ~F  # Flagged (yellow)
color index      color$BASE08 color$BASE00 ~D  # Deleted (red)
color index      color$BASE0E color$BASE00 ~T  # Tagged (magenta)

# Headers
color header     color$BASE0D color$BASE00 "^(From|To|Cc|Bcc):"
color header     color$BASE0E color$BASE00 "^Subject:"
color header     color$BASE0C color$BASE00 "^Date:"
color header     color$BASE03 color$BASE00 "^.*:"

# Body highlighting
color body       color$BASE0D color$BASE00 "https?://[^ ]+"     # URLs (blue)
color body       color$BASE0B color$BASE00 "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}"  # Emails (green)
color body       color$BASE0A color$BASE00 "^[-_+*> ]*[*][-_+*> ]*\$"  # Bold (yellow)
color body       color$BASE0C color$BASE00 "^[-_+*> ]*[/][-_+*> ]*\$"  # Italic (cyan)

# Quoted text
color quoted     color$BASE0C color$BASE00  # First level (cyan)
color quoted1    color$BASE0B color$BASE00  # Second level (green)
color quoted2    color$BASE0A color$BASE00  # Third level (yellow)
color quoted3    color$BASE0E color$BASE00  # Fourth level (magenta)

# Sidebar (if enabled)
color sidebar_new       color$BASE0B color$BASE00  # New mail (green)
color sidebar_flagged   color$BASE0A color$BASE00  # Flagged (yellow)
color sidebar_highlight color$BASE00 color$BASE0D  # Selected folder (blue bg)

# Search highlighting
color search     color$BASE00 color$BASE0A  # Search matches (yellow bg)

# Attachment
color attachment color$BASE0E color$BASE00  # Attachments (magenta)

# Signature
color signature  color$BASE03 color$BASE00  # Signature (muted)

# Progress bar
color progress   color$BASE00 color$BASE0D  # Progress (blue bg)
NEOMUTT_EOF

# If main neomutt config exists, ensure it sources colors
if [ -f ~/.config/neomutt/neomuttrc ]; then
    if ! grep -q "source.*colors" ~/.config/neomutt/neomuttrc; then
        echo "" >> ~/.config/neomutt/neomuttrc
        echo "# Auto-themed colors" >> ~/.config/neomutt/neomuttrc
        echo "source ~/.config/neomutt/colors" >> ~/.config/neomutt/neomuttrc
    fi
fi

# Sync calcurse (Calendar)
mkdir -p ~/.calcurse
if [ ! -f ~/.calcurse/conf ]; then
    # Create basic config if it doesn't exist
    calcurse-upgrade 2>/dev/null || true
fi

# Convert hex to calcurse color names
# calcurse uses color names, not hex, so we map base16 to nearest color
cat > ~/.calcurse/conf << CALCURSE_EOF
# calcurse configuration - Auto-synced with system theme

appearance.calendarview=monthly
appearance.compactpanels=no
appearance.defaultpanel=calendar
appearance.layout=1
appearance.headerline=yes
appearance.eventseparator=yes
appearance.dayseparator=yes
appearance.emptyline=yes
appearance.notifybar=yes
appearance.sidebarwidth=1
appearance.theme=custom
appearance.todoview=show-completed

# Auto-themed colors (mapped from base16)
# Background/foreground
general.background=default
general.foreground=default

# Calendar colors
calendar.today=reverse
calendar.event=cyan
calendar.appointment=blue

# Panel colors
panel.header=yellow
panel.footer=cyan

# Todo colors
todo.done=green
todo.priority.low=cyan
todo.priority.medium=yellow
todo.priority.high=red

# Notification colors
notification.warning=yellow
notification.error=red
notification.info=cyan

# Status bar
statusbar.background=default
statusbar.foreground=cyan

# Selection
selected=reverse

# Progress
progress.bar=cyan
CALCURSE_EOF

# Sync taskwarrior (task)
mkdir -p ~/.task
cat > ~/.task/hedgehog.theme << TASK_EOF
# Taskwarrior Hedgehog Theme - Auto-synced with system theme

# General
rule.precedence.color=deleted,completed,active,keyword.,tag.,project.,overdue,scheduled,due.today,due,blocked,blocking,recurring,tagged,uda.

# Colors
color.label=
color.label.sort=
color.alternate=
color.header=cyan
color.footnote=cyan
color.warning=yellow
color.error=red
color.debug=blue

# Task states
color.completed=green
color.deleted=red
color.active=reverse
color.recurring=magenta
color.scheduled=cyan
color.until=
color.blocked=white on red
color.blocking=white on yellow

# Project
color.project.none=

# Priority
color.uda.priority.H=red
color.uda.priority.M=yellow
color.uda.priority.L=cyan

# Tags
color.tag.next=reverse
color.tag.none=
color.tagged=cyan

# Due dates
color.due.today=red
color.due=yellow
color.overdue=bold red

# Report
color.burndown.done=green
color.burndown.pending=yellow
color.burndown.started=blue

# Calendar
color.calendar.due.today=red
color.calendar.due=yellow
color.calendar.holiday=magenta
color.calendar.today=reverse
color.calendar.weekend=cyan
color.calendar.weeknumber=blue

# Sync
color.sync.added=green
color.sync.changed=yellow
color.sync.rejected=red

# Undo
color.undo.before=yellow
color.undo.after=green
TASK_EOF

# Add to taskrc if it exists
if [ ! -f ~/.taskrc ]; then
    cat > ~/.taskrc << TASKRC_EOF
# Taskwarrior configuration
data.location=~/.task

# Use hedgehog theme
include ~/.task/hedgehog.theme

# Other settings
search.case.sensitive=no
TASKRC_EOF
else
    if ! grep -q "hedgehog.theme" ~/.taskrc; then
        echo "" >> ~/.taskrc
        echo "# Auto-themed colors" >> ~/.taskrc
        echo "include ~/.task/hedgehog.theme" >> ~/.taskrc
    fi
fi

# Sync jq (JSON processor)
# jq uses terminal colors when --color-output is used
# Create alias to always use color
mkdir -p ~/.config/jq
echo "# jq uses terminal colors automatically with -C flag" > ~/.config/jq/README

# Note: nb and jrnl use $EDITOR (neovim) which is already themed

echo " All apps synced to current theme!"
echo "   � ncmpcpp: ~/.config/ncmpcpp/config"
echo "   � spotify-player: ~/.config/spotify-player/theme.toml"
echo "   � cmus: ~/.config/cmus/hedgehog.theme"
echo "   � gomuks: ~/.config/gomuks/themes/hedgehog.yaml"
echo "   � neomutt: ~/.config/neomutt/colors"
echo "   � calcurse: ~/.calcurse/conf"
echo "   � task: ~/.task/hedgehog.theme"
echo ""
echo "Restart apps to see changes."
SYNCEOF

chmod +x "$USER_HOME/.local/bin/sync-music-themes"

# Run initial sync
echo "Syncing music player themes with system theme..."
sudo -u "$ACTUAL_USER" bash "$USER_HOME/.local/bin/sync-music-themes"

echo " Theme Maker installed!"
echo "   Commands:"
echo "   - thememaker: Interactive theme creator"
echo "   - wal-theme: Generate theme from images (pywal)"
echo "   - sync-music-themes: Sync music/chat apps to current theme"

# Add ~/.local/bin to PATH in bash
if ! grep -q 'PATH.*\.local/bin' "$USER_HOME/.bashrc" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" tee -a "$USER_HOME/.bashrc" > /dev/null << 'PATHEOF'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
PATHEOF
fi

# Add ~/.local/bin to PATH in zsh (if exists)
if [ -f "$USER_HOME/.zshrc" ] && ! grep -q 'PATH.*\.local/bin' "$USER_HOME/.zshrc" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" tee -a "$USER_HOME/.zshrc" > /dev/null << 'PATHEOF'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
PATHEOF
fi

echo "Application launcher created! Run 'apps' to launch."

# Set up pass (password manager)
echo "========================================="
echo "Setting up pass (password manager)..."
echo "========================================="

echo ""
echo "NOTE: To use pass, you need to initialize it with your GPG key:"
echo "  1. Generate GPG key (if you don't have one):"
echo "     gpg --full-generate-key"
echo "  2. Initialize pass with your GPG email:"
echo "     pass init your-email@example.com"
echo "  3. Start adding passwords:"
echo "     pass insert email/gmail"
echo "     pass show email/gmail"
echo ""

# Set up neomutt for Gmail
echo "========================================="
echo "Setting up neomutt for Gmail..."
echo "========================================="

NEOMUTT_CONFIG="$USER_HOME/.config/neomutt"
sudo -u "$ACTUAL_USER" mkdir -p "$NEOMUTT_CONFIG"

# Create neomutt config file
sudo -u "$ACTUAL_USER" tee "$NEOMUTT_CONFIG/neomuttrc" > /dev/null <<'EOF'
# Gmail Configuration for Neomutt
# Replace YOUR_EMAIL@gmail.com with your actual Gmail address

# Account Settings
set from = "YOUR_EMAIL@gmail.com"
set realname = "Your Name"

# IMAP Settings
set imap_user = "YOUR_EMAIL@gmail.com"
set imap_pass = ""  # Leave empty to be prompted, or use app-specific password

set folder = "imaps://imap.gmail.com:993"
set spoolfile = "+INBOX"
set postponed = "+[Gmail]/Drafts"
set record = "+[Gmail]/Sent Mail"
set trash = "+[Gmail]/Trash"

# SMTP Settings
set smtp_url = "smtps://YOUR_EMAIL@gmail.com@smtp.gmail.com:465"
set smtp_pass = ""  # Leave empty to be prompted, or use app-specific password

# Connection Settings
set ssl_force_tls = yes
set ssl_starttls = yes

# Mailboxes
mailboxes =INBOX =[Gmail]/Sent\ Mail =[Gmail]/Drafts =[Gmail]/Spam =[Gmail]/Trash

# General Settings
set editor = "nvim"
set sort = threads
set sort_aux = reverse-last-date-received
set mail_check = 60
set timeout = 10

# UI Settings
set sidebar_visible = yes
set sidebar_width = 30
set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?%S"

# Key bindings
bind index,pager \Ck sidebar-prev
bind index,pager \Cj sidebar-next
bind index,pager \Co sidebar-open
bind index,pager B sidebar-toggle-visible

# Colors (basic)
color sidebar_new yellow default
color normal white default
color indicator black cyan
color status cyan default
EOF

echo ""
echo "NOTE: Neomutt has been installed and configured for Gmail."
echo "To use it:"
echo "  1. Edit ~/.config/neomutt/neomuttrc"
echo "  2. Replace YOUR_EMAIL@gmail.com with your Gmail address"
echo "  3. Replace 'Your Name' with your actual name"
echo "  4. Set up a Gmail App Password at: https://myaccount.google.com/apppasswords"
echo "  5. Either add your app password to the config or leave empty to be prompted"
echo "  6. Colors auto-sync with your system theme!"
echo ""

# Set up Docker permissions
echo "========================================="
echo "Setting up Docker permissions..."
echo "========================================="

if getent group docker > /dev/null 2>&1; then
    usermod -aG docker "$ACTUAL_USER"
    echo "User added to docker group. Reboot required for docker commands to work without sudo."
else
    echo "WARNING: docker group not found. Docker may not be installed yet."
    echo "Run 'sudo usermod -aG docker \$USER' after reboot if needed."
fi

# Set up MPD (Music Player Daemon) for ncmpcpp
echo "========================================="
echo "Setting up MPD for ncmpcpp..."
echo "========================================="

MPD_CONFIG_DIR="$USER_HOME/.config/mpd"
sudo -u "$ACTUAL_USER" mkdir -p "$MPD_CONFIG_DIR"
sudo -u "$ACTUAL_USER" mkdir -p "$USER_HOME/Music"

# Create MPD configuration
sudo -u "$ACTUAL_USER" tee "$MPD_CONFIG_DIR/mpd.conf" > /dev/null <<'EOF'
# MPD Configuration for Hedgehog OS

# Music directory
music_directory    "~/Music"

# Playlists directory
playlist_directory "~/.config/mpd/playlists"

# Database file
db_file            "~/.config/mpd/database"

# Log file
log_file           "~/.config/mpd/log"

# PID file
pid_file           "~/.config/mpd/pid"

# State file
state_file         "~/.config/mpd/state"

# Sticker database
sticker_file       "~/.config/mpd/sticker.sql"

# Audio output (PulseAudio/Pipewire)
audio_output {
    type        "pulse"
    name        "PulseAudio Output"
}

# Optional: FIFO output for visualizers (cava)
audio_output {
    type        "fifo"
    name        "FIFO Output for Visualizers"
    path        "/tmp/mpd.fifo"
    format      "44100:16:2"
}

# Bind to localhost only
bind_to_address "127.0.0.1"
port            "6600"

# User-level MPD (not system-wide)
auto_update "yes"
EOF

# Create required directories
sudo -u "$ACTUAL_USER" mkdir -p "$MPD_CONFIG_DIR/playlists"

# Enable and start MPD as user service
echo "Enabling MPD user service..."
sudo -u "$ACTUAL_USER" systemctl --user enable mpd
sudo -u "$ACTUAL_USER" systemctl --user start mpd 2>/dev/null || echo "MPD will start on first login"

echo "MPD configured for ncmpcpp and cava visualization"

# Note: gtrash alias will be added with main aliases below

# Create a simple shell profile enhancement
echo "========================================="
echo "Enhancing shell profile..."
echo "========================================="

BASHRC="$USER_HOME/.bashrc"
# Ensure .bashrc exists
sudo -u "$ACTUAL_USER" touch "$BASHRC"

if ! grep -q "# TUI System Aliases" "$BASHRC"; then
    sudo -u "$ACTUAL_USER" tee -a "$BASHRC" > /dev/null <<'EOF'

# TUI System Aliases
alias fm='yazi'
alias monitor='btop'
alias fetch='fastfetch'
alias vim='nvim'
alias vi='nvim'
alias bt='bluetuith'
alias weather='outside'
alias music='spotify-player'
alias mail='neomutt'
alias note='nb'
alias journal='jrnl'
alias preview='glow'
alias todo='todo.sh'
alias timer='termdown'
alias chat='gomuks'
alias wiki='wiki-tui'

# Modern CLI tool aliases
alias cat='bat --paging=never'
alias ls='eza --icons'
alias ll='eza -la --icons'
alias tree='eza --tree --icons'
alias find='fd'
alias grep='rg'
alias jq='jq -C'

# Safety aliases
alias rm='gtrash put'

# Artsy aliases
alias matrix='cxxmatrix'
alias pipes='pipes.sh -R'
alias bonsai='cbonsai -l'
alias art='figlet -f slant'
alias rainbow='lolcat'

# Theme maker aliases
alias theme='thememaker'
alias themegen='wal-theme'
alias musictheme='sync-music-themes'

# Pywal support (if installed)
if [ -f ~/.cache/wal/colors.sh ]; then
    source ~/.cache/wal/colors.sh
fi

# base16-shell theming
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && source "$BASE16_SHELL/profile_helper.sh"

# Auto-sync music themes when base16 theme changes
if [ -n "$BASE16_THEME" ] && [ "$BASE16_THEME" != "$LAST_BASE16_THEME" ]; then
    export LAST_BASE16_THEME="$BASE16_THEME"
    if command -v sync-music-themes &> /dev/null; then
        sync-music-themes > /dev/null 2>&1
    fi
fi

# fzf key bindings and fuzzy completion
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

# Show system info on login with custom art
rxfetch 2>/dev/null || fastfetch
EOF
fi

# If using zsh
ZSHRC="$USER_HOME/.zshrc"
# Ensure .zshrc exists
sudo -u "$ACTUAL_USER" touch "$ZSHRC"

if [ -f "$ZSHRC" ]; then
    if ! grep -q "# TUI System Aliases" "$ZSHRC"; then
        sudo -u "$ACTUAL_USER" tee -a "$ZSHRC" > /dev/null <<'EOF'

# TUI System Aliases
alias fm='yazi'
alias monitor='btop'
alias fetch='fastfetch'
alias vim='nvim'
alias vi='nvim'
alias bt='bluetuith'
alias weather='outside'
alias music='spotify-player'
alias mail='neomutt'
alias note='nb'
alias journal='jrnl'
alias preview='glow'
alias todo='todo.sh'
alias timer='termdown'
alias chat='gomuks'
alias wiki='wiki-tui'

# Artsy aliases
alias matrix='cxxmatrix'
alias pipes='pipes.sh -R'
alias bonsai='cbonsai -l'
alias art='figlet -f slant'
alias rainbow='lolcat'

# Theme maker aliases
alias theme='thememaker'
alias themegen='wal-theme'
alias musictheme='sync-music-themes'

# Pywal support (if installed)
if [ -f ~/.cache/wal/colors.sh ]; then
    source ~/.cache/wal/colors.sh
fi

# base16-shell theming
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && source "$BASE16_SHELL/profile_helper.sh"

# Auto-sync music themes when base16 theme changes
if [ -n "$BASE16_THEME" ] && [ "$BASE16_THEME" != "$LAST_BASE16_THEME" ]; then
    export LAST_BASE16_THEME="$BASE16_THEME"
    if command -v sync-music-themes &> /dev/null; then
        sync-music-themes > /dev/null 2>&1
    fi
fi

# fzf key bindings and fuzzy completion
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Show system info on login with custom art
rxfetch 2>/dev/null || fastfetch
EOF
    fi
fi

echo "========================================="
echo "Post-install setup complete!"
echo "========================================="
echo ""
echo "Installed tools:"
echo "  - yazi: Terminal file manager (run 'yazi' or 'fm')"
echo "  - btop: System monitor (run 'btop' or 'monitor')"
echo "  - fastfetch: System info (run 'fastfetch' or 'fetch')"
echo "  - neovim with LazyVim: Editor (run 'nvim')"
echo "  - lazygit: Git TUI (run 'lazygit')"
echo "  - impala: Process explorer"
echo "  - bluetuith: Bluetooth manager (run 'bluetuith' or 'bt')"
echo "  - outside: Weather client (run 'outside' or 'weather')"
echo "  - spotify-player: Spotify TUI (run 'spotify-player' or 'music')"
echo "  - gtrash: Safe rm alternative (aliased to 'rm')"
echo "  - neomutt: Email client configured for Gmail (run 'neomutt' or 'mail')"
echo "  - navi: Interactive cheatsheet tool (run 'navi')"
echo "  - lazydocker: Docker management TUI (run 'lazydocker')"
echo ""
echo "Writer Tools:"
echo "  - nb: CLI note-taking (run 'nb')"
echo "  - jrnl: Command-line journal (run 'jrnl')"
echo "  - vimwiki: Personal wiki in Neovim (press <leader>ww in nvim)"
echo "  - glow: Markdown renderer (run 'glow')"
echo "  - pandoc: Document converter (run 'pandoc')"
echo "  - languagetool: Grammar checker (run 'languagetool')"
echo "  - task: Taskwarrior task manager (run 'task')"
echo "  - todotxt: Simple todo list (run 'todo.sh')"
echo "  - peaclock: Terminal clock (run 'peaclock')"
echo "  - termdown: Countdown timer (run 'termdown 25m')"
echo "  - fzf: Fuzzy finder (run 'fzf' or Ctrl+R in shell)"
echo "  - zathura: PDF viewer (run 'zathura file.pdf')"
echo "  - papis: Reference manager (run 'papis')"
echo ""
echo "Artsy Tools:"
echo "  - chafa: Image viewer in terminal (run 'chafa image.jpg')"
echo "  - viu: Image viewer with true color (run 'viu image.jpg')"
echo "  - pipes.sh: Animated pipes (run 'pipes.sh')"
echo "  - genact: Fake activity generator (run 'genact')"
echo "  - ncmpcpp: Music player with visualizer (run 'ncmpcpp')"
echo "  - cava: Audio visualizer (run 'cava')"
echo "  - cbonsai: Bonsai tree generator (run 'cbonsai')"
echo "  - rain: Rain animation (run 'rain')"
echo "  - mapscii: World map in terminal (run 'mapscii')"
echo "  - unimatrix: Matrix effect (run 'unimatrix')"
echo "  - termgraph: Terminal graphs (run 'termgraph')"
echo "  - cxxmatrix: Advanced Matrix effect (run 'cxxmatrix')"
echo "  - lavat: Lava lamp simulation (run 'lavat')"
echo "  - rxfetch: System info with custom ASCII art (run 'rxfetch')"
echo "  - figlet: ASCII text banners (run 'figlet text')"
echo "  - lolcat: Rainbow colorize output (run 'echo text | lolcat')"
echo "  - termsaver: Terminal screensavers (run 'termsaver matrix')"
echo ""
echo "Terminal Emulator:"
echo "  - alacritty: GPU-accelerated terminal (run 'alacritty')"
echo "  - Config: ~/.config/alacritty/alacritty.toml"
echo ""
echo "Chat & Communication:"
echo "  - gomuks: Matrix/Element client with E2E encryption (run 'gomuks')"
echo "  - irssi: IRC client (run 'irssi')"
echo "  - neomutt: Email client for Gmail (run 'neomutt' or 'mail')"
echo "  - meshtastic: Off-grid mesh communication CLI (run 'meshtastic --help')"
echo ""
echo "Productivity & System:"
echo "  - tmux: Terminal multiplexer (run 'tmux')"
echo "  - newsboat: RSS/Atom feed reader (run 'newsboat')"
echo "  - iftop: Network bandwidth monitoring (run 'sudo iftop')"
echo "  - calcurse: Calendar and scheduling (run 'calcurse')"
echo ""
echo "Theming:"
echo "  - base16-shell: Global theme system with 200+ themes"
echo "  - Change theme: base16_mocha, base16_nord, base16_gruvbox-dark"
echo "  - List themes: 'base16' then TAB for autocomplete"
echo "  - Theme applies to: Alacritty, Neovim, tmux, and all TUI apps"
echo ""
echo "APPLICATION LAUNCHER:"
echo "   Type 'apps' to launch the application selector!"
echo "   Browse all 90+ apps organized by category with fuzzy search"
echo ""
echo "Modern CLI Essentials:"
echo "  - rsync: File sync and backups (run 'rsync -avz src/ dest/')"
echo "  - ripgrep: Fast search (run 'rg pattern')"
echo "  - bat: Enhanced cat with syntax highlighting (run 'bat file')"
echo "  - eza: Modern ls replacement (run 'eza -la')"
echo "  - fd: Fast find alternative (run 'fd pattern')"
echo "  - jq: JSON processor (run 'cat file.json | jq')"
echo "  - ffmpeg: Video/audio processing (run 'ffmpeg -i input.mp4')"
echo ""
echo "Research & Reference:"
echo "  - wikit: Quick Wikipedia lookups (run 'wikit \"topic\"')"
echo "  - wiki-tui: Interactive Wikipedia browser (run 'wiki-tui')"
echo "  - lynx/w3m: Full web browsers for Wikipedia (run 'lynx en.wikipedia.org')"
echo ""
echo "Essential Utilities:"
echo "  - pass: Password manager with GPG encryption (run 'pass')"
echo "  - aspell: Spell checker for writing (run 'aspell check file.txt')"
echo "  - bc: Calculator (run 'bc' or 'echo \"2+2\" | bc')"
echo "  - qalc: Advanced calculator (run 'qalc')"
echo "  - wordnet: Dictionary and thesaurus (run 'wn word -synsn')"
echo "  - p7zip: 7z archive support (run '7z a archive.7z files/')"
echo "  - topgrade: Update all tools at once (run 'topgrade')"
echo "  - pulsemixer: TUI volume control (run 'pulsemixer')"
echo "  - yt-dlp: Download videos/audio (run 'yt-dlp URL')"
echo "  - smartmontools: Disk health monitoring (run 'sudo smartctl -a /dev/sda')"
echo "  - openssh: SSH client for remote access (run 'ssh user@host')"
echo "  - tldr: Simplified man pages (run 'tldr command')"
echo ""
echo "Theme Creators:"
echo "  - thememaker: Interactive TUI theme builder (run 'thememaker' or 'theme')"
echo "  - wal-theme: Generate themes from images with pywal (run 'wal-theme image.jpg')"
echo "  - base16: 200+ built-in themes (run 'base16_nord', 'base16_monokai', etc)"
echo "  - sync-music-themes: Sync all apps to current theme (auto-runs on theme change)"
echo ""
echo "File Sharing:"
echo "  - croc: Encrypted file transfer anywhere (run 'croc send file')"
echo "  - localsend: Fast local network file sharing (run 'localsend send file')"
echo ""
echo "Note: On first launch of nvim, LazyVim will install plugins."
echo "This may take a few minutes."
echo ""
echo "Reboot or re-login to apply all changes."

