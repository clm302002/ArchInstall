#!/bin/bash

# Enable debug output and exit on error
set -euxo pipefail

LOGFILE=archinstall.log
exec > >(tee -a "$LOGFILE") 2>&1

echo "========== [ArchInstall Started] =========="
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

echo "[+] Copying dotfiles..."
cp -rv dotfiles/.config ~/
cp -rv dotfiles/.local ~/

echo "[+] Copying home directory files..."
cp -v home-files/volume-*.sh ~/
chmod +x ~/volume-*.sh


echo "[+] Enabling user services..."
CACHE_SCRIPT="$HOME/.config/scripts/cache_sink_ids.sh"
CACHE_SERVICE="$HOME/.config/systemd/user/cache_sink_ids.service"

if [[ -f "$CACHE_SCRIPT" ]]; then
    echo "    ↪ Making cache_sink_ids.sh executable..."
    chmod +x "$CACHE_SCRIPT"
else
    echo "    ⚠️  Script not found at $CACHE_SCRIPT"
fi

if [[ -f "$CACHE_SERVICE" ]]; then
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable cache_sink_ids.service
    systemctl --user start cache_sink_ids.service
else
    echo "    ⚠️  Service file not found at $CACHE_SERVICE"
fi

# ─────────────────────────────────────────────
# 🖥️ Optional: Setup Dual Ultrawide Monitors
# ─────────────────────────────────────────────
read -p "🖥️  Apply Nano's dual ultrawide monitor layout? (y/n): " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    if [[ -f scripts/setup-monitors.sh ]]; then
        echo "🖥️  Applying saved monitor layout..."
        bash scripts/setup-monitors.sh && echo "✅ Monitor layout applied."
    else
        echo "❌ Monitor layout script not found."
    fi
else
    echo "⏭️  Skipping monitor layout setup."
fi

# ─────────────────────────────────────────────
# 📦 Installing System Packages
# ─────────────────────────────────────────────
echo "[+] Installing pacman packages..."
sudo pacman -S --needed --noconfirm $(< packages/pacman.txt)

echo "[+] Enabling multilib and UI options in pacman.conf..."
sudo sed -i 's/^#\s*\(ParallelDownloads\|MAKEFLAGS\|Color\)/\1/' /etc/pacman.conf
sudo sed -i 's/^#\s*\(\[multilib\]\)/\1/' /etc/pacman.conf
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
sudo pacman -Sy

# ─────────────────────────────────────────────
# 📦 Installing Yay (AUR Helper)
# ─────────────────────────────────────────────
echo "[+] Installing prerequisites for AUR builds..."
sudo pacman -S --needed --noconfirm base-devel git

echo "[+] Cloning yay from AUR..."
cd ~
rm -rf yay
git clone https://aur.archlinux.org/yay.git || { echo "[!] Failed to clone yay"; exit 1; }

echo "[+] Building and installing yay..."
cd yay
makepkg -si --noconfirm || { echo "[!] Failed to build yay"; exit 1; }

cd ..
rm -rf yay
cd "$(dirname "$0")"

echo "[+] Installing AUR packages..."
yay -S --needed --noconfirm $(< "$SCRIPT_DIR/packages/aur.txt")

echo "[+] Installing flatpak..."
sudo pacman -S --needed --noconfirm flatpak

echo "[+] Adding Flathub remote if not already added..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "[+] Installing Flatpak packages..."
while read -r app; do
    flatpak install -y flathub "$app"
done < "$SCRIPT_DIR/packages/flatpak.txt"

# ─────────────────────────────────────────────
# 🌓  Optional: Apply Breeze Dark Theme
# ─────────────────────────────────────────────
read -p "🌓  Would you like to apply the Breeze Dark KDE theme? (y/n): " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "🛠️  Installing lookandfeeltool (plasma-workspace)..."
    sudo pacman -S --needed --noconfirm plasma-workspace

    echo "🎨 Applying Breeze Dark global theme..."
    if command -v lookandfeeltool &> /dev/null; then
        lookandfeeltool -a org.kde.breezedark.desktop && echo "✅ Breeze Dark applied."
    else
        echo "❌ Failed to apply Breeze Dark: lookandfeeltool not found."
    fi
else
    echo "⏭️  Skipping Breeze Dark theme setup."
fi


# ─────────────────────────────────────────────
# 🔐  Optional: Setup SDDM Theme + Lock Screen
# ─────────────────────────────────────────────
read -p "🔐  Apply Sugar Candy SDDM theme and set lock/login background to arch.jpeg? (y/n): " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "🎨 Installing Sugar Candy SDDM theme..."
    yay -S --needed --noconfirm sddm-sugar-candy-git

    echo "⚙️  Setting Sugar Candy as default SDDM theme..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/10-theme.conf > /dev/null <<EOF
[Theme]
Current=sddm-sugar-candy
EOF

    echo "🖼️  Setting login background to arch.jpeg..."
    sudo tee /etc/sddm.conf.d/20-background.conf > /dev/null <<EOF
[General]
Background=/home/$USER/Pictures/arch.jpeg
EOF

    echo "🔒 Setting lock screen wallpaper..."
    sudo pacman -S --needed --noconfirm kde-cli-tools
    mkdir -p ~/.config
    kwriteconfig5 --file kscreenlockerrc --group Greeter --key Background "/home/$USER/Pictures/arch.jpeg"
    echo "✅ Lock screen background set to arch.jpeg"
else
    echo "⏭️  Skipping SDDM and lock screen setup."
fi

# ─────────────────────────────────────────────
# 💾 Optional: Mount Unmounted Disks
# ─────────────────────────────────────────────
read -p "💾  Would you like to mount additional unmounted drives now? (y/n): " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "🔍 Scanning for unmounted partitions..."
    lsblk -rno NAME,MOUNTPOINT | while read -r name mount; do
        if [[ -z "$mount" && "$name" != *"zram"* ]]; then
            device="/dev/$name"
            suggested_name=$(lsblk -no LABEL "$device" | tr ' ' '_' || echo "$name")

            echo -e "\n📦 Found: $device (No mount point)"
            read -p "👉  Mount this drive? (y/n): " mount_answer
            if [[ "$mount_answer" =~ ^[Yy]$ ]]; then
                read -p "📛  Mount name (default: $suggested_name): " custom_name
                mount_name="${custom_name:-$suggested_name}"
                mount_path="/mnt/$mount_name"

                echo "📂 Creating mount point at $mount_path"
                sudo mkdir -p "$mount_path"

                echo "🔗 Mounting $device to $mount_path..."
                sudo mount "$device" "$mount_path" && echo "✅ Mounted $device to $mount_path"

                read -p "📝  Add to /etc/fstab for auto-mount at boot? (y/n): " fstab_answer
                if [[ "$fstab_answer" =~ ^[Yy]$ ]]; then
                    uuid=$(blkid -s UUID -o value "$device")
                    fstype=$(blkid -s TYPE -o value "$device")
                    echo "UUID=$uuid $mount_path $fstype defaults,noatime 0 2" | sudo tee -a /etc/fstab
                    echo "✅ Added to /etc/fstab"
                fi
            fi
        fi
    done
else
    echo "⏭️  Skipping disk mounting."
fi

# ─────────────────────────────────────────────
# 🧪 Optional: Fusion 360 Setup
# ─────────────────────────────────────────────
read -p "Would you like to clone the Fusion 360 setup repo? (y/n): " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "[+] Cloning Fusion 360 setup repo..."
    git clone https://github.com/brinkervii/arch-fusion360.git ~/arch-fusion360
    echo "[✓] Fusion 360 setup cloned to ~/arch-fusion360"
else
    echo "[!] Skipping Fusion 360 setup."
fi

echo "========== [ArchInstall Complete] =========="
