#!/bin/bash

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

echo "[+] Installing pacman packages..."
sudo pacman -S --needed --noconfirm $(< packages/pacman.txt)

echo "[+] Installing AUR packages..."
yay -S --needed --noconfirm $(< packages/aur.txt)

echo "[+] Installing Flatpak packages..."
while read -r app; do
    flatpak install -y flathub "$app"
done < packages/flatpak.txt

echo "[+] Copying dotfiles..."
cp -r dotfiles/.config ~/
cp -r dotfiles/.local ~/

echo "[+] Copying home directory files..."
cp home-files/volume-*.sh ~/
chmod +x ~/volume-*.sh

echo "[+] Enabling user services..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable cache_sink_ids.service
systemctl --user start cache_sink_ids.service

echo "[+] Install complete."
