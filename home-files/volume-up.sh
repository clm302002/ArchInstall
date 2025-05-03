#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

astro_id=$(cat /tmp/astro_a50_game.id)
starship_id=$(cat /tmp/starship_analog.id)

wpctl set-volume "$astro_id" 5%+
wpctl set-volume "$starship_id" 5%+
