#!/bin/bash

# Get the absolute path to the rofi config directory
ROFI_CONFIG_DIR="$HOME/.config/rofi"

# Launch iwmenu with custom rofi theme using absolute path
iwmenu -l custom --launcher-command "rofi -dmenu -theme $ROFI_CONFIG_DIR/iwmenu/style.rasi -p 'WiFi'" 