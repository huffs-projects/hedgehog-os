#!/bin/bash

# PlanigaleOS Build Script
# Creates a complete TUI-only Linux distribution for Raspberry Pi 3 A+

set -e

# Configuration
DISTRO_NAME="planigale-os"
VERSION="1.0.0"
TARGET_ARCH="armhf"
PI_MODEL="3A+"
IMAGE_SIZE="8G"
BUILD_DIR="build"
OUTPUT_DIR="output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
    
    # Check if user has sudo access
    if ! sudo -n true 2>/dev/null; then
        log_error "This script requires sudo access. Please run with a user that has sudo privileges."
        exit 1
    fi
    
    log_success "User has sudo access"
}

# Check dependencies
check_dependencies() {
    log_info "Checking build dependencies..."
    
    local deps=("debootstrap" "qemu-user-static" "kpartx" "parted" "e2fsprogs" "dosfstools")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi
    
    # Check available disk space (need at least 10GB)
    local available_space=$(df . | tail -1 | awk '{print $4}')
    local required_space=10485760  # 10GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "Insufficient disk space. Need at least 10GB, have $(($available_space / 1024 / 1024))GB"
        exit 1
    fi
    
    log_success "All dependencies found and sufficient disk space available"
}

# Create build directories
setup_directories() {
    log_info "Setting up build directories..."
    
    # Check if config/rootfs exists
    if [ ! -d "config/rootfs" ]; then
        log_error "config/rootfs directory not found. Please ensure configuration files are present."
        exit 1
    fi
    
    # Check if qemu-arm-static exists
    if [ ! -f "/usr/bin/qemu-arm-static" ]; then
        log_error "qemu-arm-static not found. Please install qemu-user-static package."
        exit 1
    fi
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR/boot"
    
    log_success "Build directories created"
}

# Create base system
create_base_system() {
    log_info "Creating base system with debootstrap..."
    
    # Test network connectivity
    if ! ping -c 1 raspbian.raspberrypi.org >/dev/null 2>&1; then
        log_error "Cannot reach raspbian.raspberrypi.org. Check internet connection."
        exit 1
    fi
    
    # Create base system with error handling
    if ! sudo debootstrap \
        --arch="$TARGET_ARCH" \
        --variant=minbase \
        --include=systemd,systemd-sysv,dbus \
        bullseye \
        "$BUILD_DIR/rootfs" \
        http://raspbian.raspberrypi.org/raspbian/; then
        log_error "debootstrap failed. Check network connection and disk space."
        exit 1
    fi
    
    # Verify rootfs was created
    if [ ! -d "$BUILD_DIR/rootfs" ] || [ ! -f "$BUILD_DIR/rootfs/bin/bash" ]; then
        log_error "Base system creation failed. Rootfs is incomplete."
        exit 1
    fi
    
    log_success "Base system created"
}

# Configure system
configure_system() {
    log_info "Configuring system..."
    
    # Copy configuration files
    if [ -d "config/rootfs" ]; then
        sudo cp -r config/rootfs/* "$BUILD_DIR/rootfs/"
        log_info "Configuration files copied"
    fi
    
    # Copy packages list into chroot
    if [ -f "packages.list" ]; then
        sudo cp packages.list "$BUILD_DIR/rootfs/tmp/packages.list"
        log_info "Package list copied to chroot"
    fi
    
    # Configure system in chroot
    sudo chroot "$BUILD_DIR/rootfs" /bin/bash << 'EOF'
        set -e
        
        # Update package lists
        apt-get update
        
        # Install packages from list
        if [ -f /tmp/packages.list ]; then
            # Filter out comments and empty lines
            packages=$(grep -v '^#' /tmp/packages.list | grep -v '^$' | tr '\n' ' ')
            apt-get install -y $packages
        else
            echo "Package list not found, installing essential packages only"
            apt-get install -y vim nano tmux htop git curl wget
        fi
        
        # Configure systemd services
        systemctl enable ssh || true
        systemctl enable systemd-resolved || true
        systemctl enable systemd-networkd || true
        
        # Create planigale user
        useradd -m -s /bin/bash planigale
        echo "planigale:planigale" | chpasswd
        usermod -aG sudo,audio,video,plugdev,netdev planigale
        
        # Set up home directory
        chown -R planigale:planigale /home/planigale
        chmod 755 /home/planigale
        chmod 700 /home/planigale/.ssh 2>/dev/null || true
        
        # Configure hostname
        echo "planigale-os" > /etc/hostname
        
        # Configure timezone
        echo "UTC" > /etc/timezone
        ln -sf /usr/share/zoneinfo/UTC /etc/localtime
        
        # Clean up
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        rm -f /tmp/packages.list
EOF
    
    log_success "System configured"
}

# Create boot partition
create_boot_partition() {
    log_info "Creating boot partition..."
    
    # Download Raspberry Pi firmware
    local firmware_url="https://github.com/raspberrypi/firmware/archive/refs/heads/master.zip"
    local firmware_dir="$BUILD_DIR/firmware"
    
    mkdir -p "$firmware_dir"
    
    if ! wget -q "$firmware_url" -O "$firmware_dir/firmware.zip"; then
        log_error "Failed to download Raspberry Pi firmware"
        exit 1
    fi
    
    if ! unzip -q "$firmware_dir/firmware.zip" -d "$firmware_dir"; then
        log_error "Failed to extract firmware"
        exit 1
    fi
    
    # Copy boot files
    local boot_files_dir="$firmware_dir/firmware-master/boot"
    if [ -d "$boot_files_dir" ]; then
        cp "$boot_files_dir"/*.bin "$BUILD_DIR/boot/" 2>/dev/null || true
        cp "$boot_files_dir"/*.dat "$BUILD_DIR/boot/" 2>/dev/null || true
        cp "$boot_files_dir"/*.elf "$BUILD_DIR/boot/" 2>/dev/null || true
        
        # Verify essential boot files
        if [ ! -f "$BUILD_DIR/boot/bootcode.bin" ] || [ ! -f "$BUILD_DIR/boot/start.elf" ]; then
            log_error "Essential boot files missing"
            exit 1
        fi
    else
        log_error "Boot files directory not found in firmware"
        exit 1
    fi
    
    # Create config.txt
    cat > "$BUILD_DIR/boot/config.txt" << 'EOF'
# PlanigaleOS Configuration for Raspberry Pi 3 A+
# Force 32-bit mode for compatibility
arm_64bit=0

# GPU memory split (16MB for headless operation)
gpu_mem=16

# Display settings
disable_overscan=1
hdmi_force_hotplug=1
hdmi_drive=2
hdmi_group=2
hdmi_mode=82

# Audio
dtparam=audio=on

# UART for serial console
enable_uart=1

# Boot settings
boot_delay=1

# Overclock settings (conservative for stability)
arm_freq=1200
gpu_freq=400
over_voltage=0

# Disable unnecessary features for TUI-only operation
disable_splash=1
disable_overscan=1

# Disable I2C and SPI (not needed for TUI)
dtparam=i2c_arm=off
dtparam=spi=off

# Enable LED triggers
dtparam=act_led_trigger=heartbeat
dtparam=pwr_led_trigger=default-on

# USB boot mode
program_usb_boot_mode=1

# Additional optimizations
dtoverlay=pi3-miniuart-bt
EOF
    
    # Create cmdline.txt
    cat > "$BUILD_DIR/boot/cmdline.txt" << 'EOF'
console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet
EOF
    
    log_success "Boot partition created"
}

# Create image
create_image() {
    log_info "Creating PlanigaleOS image..."
    
    local image_file="$OUTPUT_DIR/${DISTRO_NAME}-${VERSION}-${PI_MODEL}.img"
    
    # Create image file
    if ! dd if=/dev/zero of="$image_file" bs=1M count=8192 status=progress; then
        log_error "Failed to create image file"
        exit 1
    fi
    
    # Partition the image
    if ! parted "$image_file" --script mklabel msdos; then
        log_error "Failed to create partition table"
        exit 1
    fi
    
    if ! parted "$image_file" --script mkpart primary fat32 8192s 139263s; then
        log_error "Failed to create boot partition"
        exit 1
    fi
    
    if ! parted "$image_file" --script mkpart primary ext4 139264s 100%; then
        log_error "Failed to create root partition"
        exit 1
    fi
    
    # Set up loop device
    local loop_device
    if ! loop_device=$(sudo losetup -f --show "$image_file"); then
        log_error "Failed to set up loop device"
        exit 1
    fi
    
    # Create partitions
    if ! sudo kpartx -av "$loop_device"; then
        log_error "Failed to create partition mappings"
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    # Format partitions
    local boot_part="/dev/mapper/$(basename "$loop_device")p1"
    local root_part="/dev/mapper/$(basename "$loop_device")p2"
    
    if ! sudo mkfs.vfat -F 32 -n BOOT "$boot_part"; then
        log_error "Failed to format boot partition"
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    if ! sudo mkfs.ext4 -F -L rootfs "$root_part"; then
        log_error "Failed to format root partition"
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    # Mount partitions
    local boot_mount="/mnt/planigale-boot"
    local root_mount="/mnt/planigale-root"
    
    mkdir -p "$boot_mount" "$root_mount"
    
    if ! sudo mount "$boot_part" "$boot_mount"; then
        log_error "Failed to mount boot partition"
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    if ! sudo mount "$root_part" "$root_mount"; then
        log_error "Failed to mount root partition"
        sudo umount "$boot_mount" 2>/dev/null || true
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    # Copy files to partitions
    if ! sudo cp -r "$BUILD_DIR/boot"/* "$boot_mount/"; then
        log_error "Failed to copy boot files"
        sudo umount "$boot_mount" "$root_mount" 2>/dev/null || true
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    if ! sudo cp -r "$BUILD_DIR/rootfs"/* "$root_mount/"; then
        log_error "Failed to copy root files"
        sudo umount "$boot_mount" "$root_mount" 2>/dev/null || true
        sudo kpartx -dv "$loop_device" 2>/dev/null || true
        sudo losetup -d "$loop_device" 2>/dev/null || true
        exit 1
    fi
    
    # Set proper permissions
    sudo chown -R root:root "$boot_mount" "$root_mount"
    sudo chmod 755 "$boot_mount" "$root_mount"
    sudo chmod 644 "$boot_mount"/*.txt 2>/dev/null || true
    
    # Sync and unmount
    sync
    sudo umount "$boot_mount" "$root_mount"
    sudo kpartx -dv "$loop_device"
    sudo losetup -d "$loop_device"
    
    # Clean up mount points
    rmdir "$boot_mount" "$root_mount"
    
    # Verify image
    if [ ! -f "$image_file" ] || [ ! -s "$image_file" ]; then
        log_error "Image creation failed or image is empty"
        exit 1
    fi
    
    local image_size=$(du -h "$image_file" | cut -f1)
    log_success "PlanigaleOS image created: $image_file ($image_size)"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    
    # Unmount any remaining partitions
    sudo umount /mnt/planigale-boot /mnt/planigale-root 2>/dev/null || true
    
    # Remove loop devices
    sudo losetup -D 2>/dev/null || true
    
    # Remove partition mappings
    sudo kpartx -dv /dev/loop* 2>/dev/null || true
    
    # Clean up build directory
    if [ -d "$BUILD_DIR" ]; then
        sudo rm -rf "$BUILD_DIR"
    fi
    
    log_success "Cleanup completed"
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    log_info "Starting PlanigaleOS build process..."
    log_info "Target: Raspberry Pi 3 A+"
    log_info "Architecture: $TARGET_ARCH"
    log_info "Version: $VERSION"
    
    check_root
    check_dependencies
    setup_directories
    create_base_system
    configure_system
    create_boot_partition
    create_image
    
    log_success "PlanigaleOS build completed successfully!"
    log_info "Image location: $OUTPUT_DIR/${DISTRO_NAME}-${VERSION}-${PI_MODEL}.img"
    log_info "Flash to SD card with: sudo dd if=$OUTPUT_DIR/${DISTRO_NAME}-${VERSION}-${PI_MODEL}.img of=/dev/sdX bs=4M status=progress"
}

# Run main function
main "$@"
