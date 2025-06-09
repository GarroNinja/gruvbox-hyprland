#!/bin/bash

# Waybar-specific iwmenu launcher
# Ensures proper environment and paths when called from waybar

# Set environment variables that might be needed
export PATH="$PATH:$HOME/.local/bin:/usr/local/bin"

# Get the absolute path to the rofi config directory
ROFI_CONFIG_DIR="$HOME/.config/rofi"

# Check if iwmenu is available
if ! command -v iwmenu &> /dev/null; then
    notify-send "Error" "iwmenu not found in PATH"
    exit 1
fi

# Check if the theme file exists
if [ ! -f "$ROFI_CONFIG_DIR/iwmenu/style.rasi" ]; then
    notify-send "Error" "iwmenu theme file not found"
    exit 1
fi

# Launch iwmenu with custom rofi theme
iwmenu -l custom --launcher-command "rofi -dmenu -theme '$ROFI_CONFIG_DIR/iwmenu/style.rasi' -p 'WiFi'" 