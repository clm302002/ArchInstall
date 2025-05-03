#!/usr/bin/env fish
clear

# Launch animation on left
chafa --animate=on --symbols=unicode --fill --size=40x20 ~/Downloads/archpepe.gif

# Give animation a moment to start
sleep 0.5

# Print system info next to it
neofetch --off

# Kill chafa process after key press
echo ""
echo "Press any key to continue..."
read -n 1
clear
