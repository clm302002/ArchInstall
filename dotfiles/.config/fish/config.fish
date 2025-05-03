# ~/.config/fish/config.fish

# Set the greeting message (optional)
set -g fish_greeting

# Set a custom PATH (optional)
# set -gx PATH $HOME/bin $PATH

if status is-interactive
    $HOME/.config/neofetch/animated-fetch.sh
end
