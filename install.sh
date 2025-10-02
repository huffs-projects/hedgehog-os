#!/bin/bash
# Hedgehog OS - One-Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/huffs-projects/hedgehog-os/main/install.sh | bash

set -e

echo ""
echo "           HEDGEHOG OS - ONE-COMMAND INSTALLER                "
echo "                                                              "
echo "  This will automatically:                                   "
echo "  1. Download configuration files                            "
echo "  2. Run archinstall (if in ISO environment)                 "
echo "  3. Run post-install (if system is installed)               "
echo "                                                              "
echo ""
echo ""

# Configuration
GITHUB_USER="huffs-projects"
GITHUB_REPO="hedgehog-os"
BRANCH="main" 
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"

# Detect environment
if [ -d /run/archiso ]; then
    ENVIRONMENT="iso"
    echo " Detected: Arch Linux ISO environment"
elif [ -f /etc/arch-release ]; then
    ENVIRONMENT="installed"
    echo " Detected: Installed Arch Linux system"
else
    echo " ERROR: This script only works on Arch Linux"
    exit 1
fi

# Check for internet
echo ""
echo "Checking internet connection..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo " ERROR: No internet connection"
    echo "   Please connect to internet first:"
    echo "   - Ethernet: Should work automatically"
    echo "   - WiFi: Run 'iwctl' to connect"
    exit 1
fi
echo " Internet connection verified"

# Download configuration files
echo ""
echo "Downloading Hedgehog OS configuration..."
mkdir -p /tmp/hedgehog-os
cd /tmp/hedgehog-os

echo "  Ü archinstall-config.json"
curl -sL "$RAW_URL/archinstall-config.json" -o archinstall-config.json || {
    echo " ERROR: Failed to download archinstall-config.json"
    echo "   Check that $RAW_URL/archinstall-config.json exists"
    exit 1
}

echo "  Ü post-install.sh"
curl -sL "$RAW_URL/post-install.sh" -o post-install.sh || {
    echo " ERROR: Failed to download post-install.sh"
    exit 1
}

chmod +x post-install.sh

echo " Configuration files downloaded"

# Execute based on environment
echo ""
if [ "$ENVIRONMENT" = "iso" ]; then
    echo ""
    echo "              RUNNING ARCHINSTALL (ISO MODE)                  "
    echo ""
    echo ""
    echo "This will:"
    echo "  1. Partition your disk"
    echo "  2. Install base Arch system (75 packages)"
    echo "  3. Configure bootloader and services"
    echo "  4. Reboot"
    echo ""
    echo "After reboot, run this command again as your user with sudo:"
    echo "  curl -sL $RAW_URL/install.sh | bash"
    echo ""
    
    # Check if archinstall is available
    if ! command -v archinstall &> /dev/null; then
        echo "Installing archinstall..."
        pacman -Sy --noconfirm archinstall
    fi
    
    # Run archinstall
    echo ""
    echo "Starting archinstall in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    
    archinstall --config /tmp/hedgehog-os/archinstall-config.json
    
    echo ""
    echo ""
    echo "                    INSTALLATION COMPLETE                     "
    echo "£"
    echo "  Next steps:                                                 "
    echo "  1. Reboot into your new system                              "
    echo "  2. Login as your user                                       "
    echo "  3. Run this ONE command:                                    "
    echo "                                                              "
    echo "     curl -sL $RAW_URL/install.sh | sudo bash                 "
    echo "                                                              "
    echo ""
    echo ""
    read -p "Press Enter to reboot..."
    reboot
    
elif [ "$ENVIRONMENT" = "installed" ]; then
    echo ""
    echo "            RUNNING POST-INSTALL (SYSTEM MODE)                "
    echo ""
    echo ""
    echo "This will:"
    echo "  1. Install yay (AUR helper)"
    echo "  2. Install 31 AUR packages"
    echo "  3. Configure all TUI applications"
    echo "  4. Set up themes, configs, and aliases"
    echo ""
    echo "This will take 30-60 minutes."
    echo ""
    
    # Check if running as root/sudo
    if [ "$EUID" -ne 0 ]; then
        echo " ERROR: Post-install must be run as root"
        echo "   Run: curl -sL $RAW_URL/install.sh | sudo bash"
        exit 1
    fi
    
    echo "Starting post-install in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    echo ""
    
    # Run post-install
    bash /tmp/hedgehog-os/post-install.sh
    
    echo ""
    echo ""
    echo "                                                              "
    echo "           HEDGEHOG OS INSTALLATION COMPLETE!               "
    echo "                                                              "
    echo "£"
    echo "                                                              "
    echo "  Reboot and enjoy your system:                               "
    echo "                                                              "
    echo "    apps           - Application launcher                     "
    echo "    base16_nord    - Change theme                             "
    echo "    btop           - System monitor                           "
    echo "    ncmpcpp        - Music player                             "
    echo "    nvim           - Text editor                              "
    echo "                                                              "
    echo "  92+ applications ready to use!                              "
    echo "                                                              "
    echo ""
    echo ""
    
    read -p "Reboot now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reboot
    else
        echo "Remember to reboot manually: sudo reboot"
    fi
fi

