#!/bin/bash

# Enable debug output and exit on error
set -euxo pipefail

LOGFILE=archinstall.log
exec > >(tee -a "$LOGFILE") 2>&1

echo "========== [ArchInstall Started] =========="

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

echo "[+] Installing pacman packages..."
sudo pacman -S --needed --noconfirm $(< packages/pacman.txt)

echo "[+] Enabling multilib and UI options in pacman.conf..."
sudo sed -i 's/^#\s*\(ParallelDownloads\|MAKEFLAGS\|Color\)/\1/' /etc/pacman.conf
sudo sed -i 's/^#\s*\(\[multilib\]\)/\1/' /etc/pacman.conf
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
sudo pacman -Sy

echo "[+] Installing yay (AUR helper)..."
sudo pacman -S --needed --noconfirm yay

echo "[+] Installing AUR packages..."
yay -S --needed --noconfirm $(< packages/aur.txt)

echo "[+] Installing flatpak..."
sudo pacman -S --needed --noconfirm flatpak

echo "[+] Adding Flathub remote if not already added..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "[+] Installing Flatpak packages..."
while read -r app; do
    flatpak install -y flathub "$app"
done < packages/flatpak.txt

echo "[+] Copying dotfiles..."
cp -rv dotfiles/.config ~/
cp -rv dotfiles/.local ~/

echo "[+] Copying home directory files..."
cp -v home-files/volume-*.sh ~/
chmod +x ~/volume-*.sh

echo "[+] Enabling user services..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable cache_sink_ids.service
systemctl --user start cache_sink_ids.service

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
    mkdir -p ~/.config
    kwriteconfig5 --file kscreenlockerrc --group Greeter --key Background "/home/$USER/Pictures/arch.jpeg"
    echo "✅ Lock screen background set to arch.jpeg"
else
    echo "⏭️  Skipping SDDM and lock screen setup."
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
