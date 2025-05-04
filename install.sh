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
