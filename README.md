# ArchInstall

A personal post-install script for quickly restoring my Arch Linux setup with all packages, configs, and tweaks.

---

## 🚀 How to Use

1. **Clone the repo** (from a live ISO or fresh install):
```bash
git clone git@github.com:clm302002/ArchInstall.git /mnt/Files/ArchInstall
cd /mnt/Files/ArchInstall
```
################################################################################
⚙️ System Setup & Required Software
📦 Core Packages to Install

Install these using pacman or yay:
```bash
sudo pacman -S plasma sddm chromium fish neofetch vlc steam steam-native-runtime networkmanager base-devel
yay -S protonup-qt visual-studio-code-bin wine winetricks
```
🔁 Enable and Start NetworkManager
```bash
sudo systemctl enable NetworkManager
sudo systemctl restart NetworkManager
```
🧩 Flatpak Setup

Install VLC via Flatpak:
```bash
flatpak install flathub org.videolan.VLC
```
🎮 Gaming Tools

    Install Steam (steam, steam-native-runtime)

    Install Proton GE via ProtonUp-Qt (yay -S protonup-qt)

    Launch protonup-qt to install the latest GE version

🧪 Fusion 360 + Wine Setup
📦 Requirements

    Wine (via wine, winetricks)

    Git (for script download)

    Override winebrowser to use xdg-open

📥 Download Script
```bash
git clone https://github.com/brinkervii/arch-fusion360.git
```
Repo: https://github.com/brinkervii/arch-fusion360
🛠️ Fix for Sign-in via Wine

Create a script to override winebrowser:
```bash
#!/bin/bash
xdg-open "$@"
```
Then:
```bash
chmod +x ~/.wine/drive_c/windows/winebrowser.bat

(or wherever you override the Wine path)
```