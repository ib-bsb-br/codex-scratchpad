#!/usr/bin/env bash
# build-debian13-usb.sh - Build Debian 13 (Trixie) amd64 USB image (BIOS+UEFI, persistent)

set -euo pipefail

# Define variables
IMG_NAME="debian13-usb.img"
IMG_SIZE="28G"                            # Size of the disk image
WORKDIR="debian13_usb_build"             # Working directory for build
MNT="$WORKDIR/mnt"                       # Mount point for root filesystem
EFI_MNT="$WORKDIR/efi"                   # Mount point for EFI system partition

# Create working directories
mkdir -p "$WORKDIR" "$MNT" "$EFI_MNT"

echo ">>> Creating empty image file..."
truncate -s $IMG_SIZE "$WORKDIR/$IMG_NAME"

echo ">>> Attaching loop device..."
LOOPDEV=$(sudo losetup --find --show "$WORKDIR/$IMG_NAME")   # e.g., /dev/loop0
echo "Loop device: $LOOPDEV"

echo ">>> Partitioning the image with GPT (BIOS+UEFI)..."
# Create GPT partition table and required partitions:
#  - Partition 1: BIOS grub partition (Type bios_grub, ~2 MiB)
#  - Partition 2: EFI system partition (Type ESP, 100 MiB FAT32)
#  - Partition 3: Root filesystem (ext4, rest of disk)
sudo parted -s "$LOOPDEV" mklabel gpt
sudo parted -s "$LOOPDEV" mkpart primary 1MiB 3MiB            # ~2 MiB BIOS grub partition
sudo parted -s "$LOOPDEV" set 1 bios_grub on
sudo parted -s "$LOOPDEV" mkpart primary fat32 3MiB 103MiB    # 100 MiB EFI System Partition
sudo parted -s "$LOOPDEV" set 2 esp on
sudo parted -s "$LOOPDEV" mkpart primary ext4 103MiB 100%     # Rest: root filesystem

# Inform kernel of new partitions, then set up loop device partitions
sudo partprobe "$LOOPDEV"
# After partprobe, /dev/loop?p1, p2, p3 should be available:
EFI_PART="${LOOPDEV}p2"
ROOT_PART="${LOOPDEV}p3"

echo ">>> Formatting partitions..."
sudo mkfs.vfat -F 32 -n "EFI" "$EFI_PART"
sudo mkfs.ext4 -F -L "DEBIAN13" "$ROOT_PART"

echo ">>> Mounting root filesystem..."
sudo mount "$ROOT_PART" "$MNT"
sudo mkdir -p "$MNT/boot/efi"
sudo mount "$EFI_PART" "$EFI_MNT"
sudo mount --bind "$EFI_MNT" "$MNT/boot/efi"

echo ">>> Bootstrapping Debian 13 (Trixie) into image..."
sudo debootstrap --arch=amd64 trixie "$MNT" http://deb.debian.org/debian/

echo ">>> Configuring chroot environment..."
# Copy DNS info for networking in chroot
sudo cp /etc/resolv.conf "$MNT/etc/resolv.conf"
# Mount pseudo-filesystems for chroot operations
sudo mount --bind /dev "$MNT/dev"
sudo mount -t proc none "$MNT/proc"
sudo mount -t sysfs none "$MNT/sys"
sudo mount -t devpts none "$MNT/dev/pts"

# Enable Trixie repositories (including non-free components for firmware)
sudo chroot "$MNT" /bin/bash -c "echo 'deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware' > /etc/apt/sources.list"
sudo chroot "$MNT" /bin/bash -c "echo 'deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware' >> /etc/apt/sources.list"
sudo chroot "$MNT" /bin/bash -c "echo 'deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware' >> /etc/apt/sources.list"

echo ">>> Installing core packages in chroot (kernel, X11, etc.)..."
sudo chroot "$MNT" apt-get update
sudo chroot "$MNT" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    linux-image-amd64 grub-pc grub-efi-amd64 sudo \
    xserver-xorg xinit xterm ratpoison \
    treesheets iwd \
    firmware-iwlwifi firmware-realtek firmware-atheros

# Install Impala (WiFi TUI) inside the chroot:
echo ">>> Installing Impala (Wi-Fi TUI)..."
IMPALA_URL="https://github.com/pythops/impala/releases/download/v0.4.1/impala_v0.4.1_x86_64-unknown-linux-gnu.tar.gz"
wget -O "$WORKDIR/impala.tar.gz" "$IMPALA_URL"
sudo chroot "$MNT" mkdir -p /usr/local/bin
sudo tar -xzf "$WORKDIR/impala.tar.gz" -C "$WORKDIR"
# Assume the tar contains a binary named 'impala'
if [ -f "$WORKDIR/impala" ]; then
  sudo mv "$WORKDIR/impala" "$MNT/usr/local/bin/impala"
  sudo chroot "$MNT" chmod +x /usr/local/bin/impala
fi

echo ">>> Setting up system configuration (autologin, X autorun, user accounts)..."
# Set root password (for safety, set to 'root' - user can change later)
sudo chroot "$MNT" /bin/bash -c "echo 'root:root' | chpasswd"

# Create an unprivileged user (e.g., 'user') with password 'user'
USERNAME="user"
sudo chroot "$MNT" useradd -m -s /bin/bash "$USERNAME"
sudo chroot "$MNT" /bin/bash -c "echo '$USERNAME:$USERNAME' | chpasswd"
sudo chroot "$MNT" usermod -aG sudo "$USERNAME"   # optional: add to sudoers

# Configure automatic login on tty1 for the user
sudo mkdir -p "$MNT/etc/systemd/system/getty@tty1.service.d"
cat << 'EOF' | sudo tee "$MNT/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin user --noclear %I $TERM
EOF

# Create the user's .bash_profile to launch X at login
cat << 'EOF' | sudo tee "$MNT/home/user/.bash_profile" > /dev/null
# .bash_profile - start X automatically on console login
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOF

# Create the user's .xinitrc to start ratpoison, TreeSheets, and Impala
cat << 'EOF' | sudo tee "$MNT/home/user/.xinitrc" > /dev/null
#!/bin/sh
# .xinitrc - X session startup for user
xsetroot -solid black &
# Launch Impala Wi-Fi TUI in an xterm (terminal window)
xterm -bg black -fg white -e impala &
# Launch TreeSheets
treesheets &
# Start the Ratpoison window manager
exec ratpoison
EOF

# Fix ownership of user home files (created as root above)
sudo chroot "$MNT" chown user:user /home/user/.bash_profile /home/user/.xinitrc

# Enable iwd daemon to start on boot (for Wi-Fi functionality)
sudo chroot "$MNT" systemctl enable iwd

echo ">>> Installing GRUB bootloader (BIOS and UEFI)..."
# Install GRUB for BIOS (MBR) and UEFI
sudo chroot "$MNT" grub-install --target=i386-pc --boot-directory=/boot --recheck "${LOOPDEV}"
sudo chroot "$MNT" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Debian --removable --no-nvram
sudo chroot "$MNT" update-grub

echo ">>> Cleanup and unmounting..."
# Unmount chroot special filesystems and partitions
sudo umount -lf "$MNT/boot/efi" || true
sudo umount -lf "$MNT/proc" || true
sudo umount -lf "$MNT/sys" || true
sudo umount -lf "$MNT/dev/pts" || true
sudo umount -lf "$MNT/dev" || true
sudo umount -lf "$MNT" || true

# Detach loop device
sudo losetup -d "$LOOPDEV"

echo "Build complete. Image is at $WORKDIR/$IMG_NAME"
