#!/bin/bash

tput civis
clear

neofetch

stty -echo -icanon time 0 min 0

key=""

while true; do
    read -t 0.01 -n 1 key && break

    for i in $(seq -w 000 013); do
        tput cup 0 0
        echo -e "\e[36m"
        cat "$HOME/.config/neofetch/frames/ascii/frame$i-ascii-art.txt"
        echo -e "\e[0m"
        sleep 0.08
        read -t 0.01 -n 1 key && break 2
    done

    tput cup 0 0
    echo -e "\e[36m"
    cat "$HOME/.config/neofetch/frames/ascii/frame013-ascii-art.txt"
    echo -e "\e[0m"
    sleep 1.5
done

# Restore terminal state
stty sane
tput cnorm
tput cup 25 0
