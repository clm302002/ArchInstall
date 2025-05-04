# ArchInstall

A personal post-install script for quickly restoring my Arch Linux setup with all packages, configs, services, visuals, and tweaks.

---

## 🚀 How to Use

Clone and run everything in one command from a fresh Arch install:
```bash
git clone https://github.com/clm302002/ArchInstall.git ~/ArchInstall && cd ~/ArchInstall && chmod +x install.sh && ./install.sh
```

---

## ⚙️ System Setup & Requirements

📦 Core Package Installation (handled by the script)

Packages are split into:
- `packages/pacman.txt` — official Arch packages
- `packages/aur.txt` — AUR packages (via yay)
- `packages/flatpak.txt` — Flatpak packages (from Flathub)

The script will automatically install all of them using:
```bash
sudo pacman -Syu --needed --noconfirm ...
yay -S --needed --noconfirm ...
flatpak install -y flathub ...
```

🔁 Enable and Start NetworkManager:
```bash
sudo systemctl enable NetworkManager
sudo systemctl restart NetworkManager
```

🧩 Flatpak Setup:
- VLC: `flatpak install flathub org.videolan.VLC`
- Spotify: `flatpak install flathub com.spotify.Client`
- Bambu Studio: `flatpak install flathub com.bambulab.BambuStudio`

🎮 Gaming Tools:
- Steam: `pacman -S steam steam-native-runtime`
- Proton GE via ProtonUp-Qt (from AUR): `yay -S protonup-qt`
- Run `protonup-qt` to install the latest GE version

---

## 🧪 Fusion 360 + Wine Setup

📦 Requirements:
- Wine (via `wine`, `winetricks`)
- Git (for script download)
- Override winebrowser to use `xdg-open`

📥 Download Setup Script:
```bash
git clone https://github.com/brinkervii/arch-fusion360.git
```
Repo: [https://github.com/brinkervii/arch-fusion360](https://github.com/brinkervii/arch-fusion360)

🛠️ Fix Sign-in via Wine:
Override the default browser with a script:
```bash
#!/bin/bash
xdg-open "$@"
```
Then place it here and make it executable:
```bash
~/.wine/drive_c/windows/winebrowser
chmod +x ~/.wine/drive_c/windows/winebrowser
```

---

## 🗃️ Included Dotfiles & Files Restored

- `~/.config/fish` — shell config
- `~/.config/neofetch` — custom animated Neofetch
- `~/.config/konsole` + `konsolerc` — terminal themes
- `~/.config/systemd/user/cache_sink_ids.service` — custom audio routing at login
- `~/.config/scripts/` — helper scripts
- `~/.local/share/applications/` — custom launchers (e.g., VIA web app)
- `~/volume-up.sh` and `~/volume-down.sh` — audio control scripts
- `~/Pictures/` — wallpapers and icons

---

✅ Assumes you're running from your installed Arch system (not from a live ISO).
