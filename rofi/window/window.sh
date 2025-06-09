#!/usr/bin/env bash
dir="$HOME/.config/rofi/window"
theme='style'
rofi \
    -show window \
    -theme "${dir}/${theme}.rasi" \
    -window-format "{w} {c} {t}" \
    -window-command "wmctrl -i -a {window}"
