#!/bin/bash
sleep 5
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Define target descriptions
astro_desc="Astro A50 Game"
starship_desc="Starship/Matisse HD Audio Controller Analog Stereo"

# Find node names based on description
astro_node=$(pactl list sinks | awk -v target="$astro_desc" '
  $1 == "Name:" {name=$2}
  $1 == "Description:" && $0 ~ target {print name; exit}
')

starship_node=$(pactl list sinks | awk -v target="$starship_desc" '
  $1 == "Name:" {name=$2}
  $1 == "Description:" && $0 ~ target {print name; exit}
')

# Now get PipeWire ID from node name
astro_id=$(pw-cli info "$astro_node" 2>/dev/null | grep -E '^[[:space:]]*id:' | awk '{print $2}')
starship_id=$(pw-cli info "$starship_node" 2>/dev/null | grep -E '^[[:space:]]*id:' | awk '{print $2}')

# Save the IDs
echo "$astro_id" > /tmp/astro_a50_game.id
echo "$starship_id" > /tmp/starship_analog.id

# Confirm output
echo "Astro A50 Game sink ID: $astro_id"
echo "Starship/Matisse Analog sink ID: $starship_id"

# Set volumes
wpctl set-volume "$astro_id" 0.80
wpctl set-volume "$starship_id" 0.80

# Link Astro A50 to Starship monitor output
pw-link alsa_output.pci-0000_2d_00.4.analog-stereo:monitor_FL alsa_output.usb-Astro_Gaming_Astro_A50-00.stereo-game:playback_FL || true
pw-link alsa_output.pci-0000_2d_00.4.analog-stereo:monitor_FR alsa_output.usb-Astro_Gaming_Astro_A50-00.stereo-game:playback_FR || true
