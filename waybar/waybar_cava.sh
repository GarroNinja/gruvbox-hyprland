#!/bin/bash

# Waybar CAVA script using the same config as terminal cava
# Based on the user's cava configuration with Gruvbox colors

# Default values - using same gradient as terminal cava
bar="▁▂▃▄▅▆▇█"
bar_width=12
bar_range=7
standby_mode=""

# Create the standby bar when no audio is playing
stbBar=""

# Calculate the length of the bar
bar_length=${#bar}

# Create dictionary to replace numbers with bar characters
dict="s/;//g"
stbAscii=$(printf '0%.0s' $(seq 1 "${bar_width}"))
asciiBar="${stbAscii//0/${stbBar}}"

dict="$dict;s/${stbAscii}/${asciiBar}/g"
i=0
while [ $i -lt "${bar_length}" ] || [ $i -lt "${bar_width}" ]; do
    if [ $i -lt "${bar_length}" ]; then
        dict="$dict;s/$i/${bar:$i:1}/g"
    fi
    ((i++))
done

# Create temporary cava config based on user's terminal settings
config_file="/tmp/waybar_cava_config"
cat >"$config_file" <<EOF
[general]
bars = ${bar_width}
sleep_timer = 1

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = ${bar_range}

[color]
# Same Gruvbox gradient as terminal cava
background = '#282828'
foreground = '#ebdbb2'

gradient = 1
gradient_count = 8
gradient_color_1 = '#fb4934'
gradient_color_2 = '#fe8019'
gradient_color_3 = '#fabd2f'
gradient_color_4 = '#b8bb26'
gradient_color_5 = '#8ec07c'
gradient_color_6 = '#83a598'
gradient_color_7 = '#d3869b'
gradient_color_8 = '#ebdbb2'
EOF

# Run cava and process output
cava -p "$config_file" | sed -u "${dict}" 