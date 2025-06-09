#!/usr/bin/env bash

dir="$HOME/.config/rofi/search/"
theme='style'

# Prompt user for search input
SEARCH_STRING=$(rofi -dmenu -p "Search" -theme "${dir}/${theme}.rasi")

[[ -z "$SEARCH_STRING" ]] && exit 1

# cd shortcut
if [[ "$SEARCH_STRING" == cd* ]]; then
    DIR_PATH=$(echo "$SEARCH_STRING" | awk '{print $2}')
    [[ -z "$DIR_PATH" ]] && DIR_PATH="$HOME"
    kitty --directory="$DIR_PATH" &
    exit
fi

# Link detection
if [[ "$SEARCH_STRING" =~ ^https?:// ]]; then
    xdg-open "$SEARCH_STRING"
    exit
elif [[ "$SEARCH_STRING" =~ ^www\. ]] || [[ "$SEARCH_STRING" =~ ^[a-zA-Z0-9.-]+\.[a-z]{2,}(/.*)?$ ]]; then
    xdg-open "https://$SEARCH_STRING"
    exit
fi

# Parse engine and query
ENGINE=$(echo "$SEARCH_STRING" | awk '{print $1}')
QUERY=$(echo "$SEARCH_STRING" | awk '{$1=""; print $0}' | sed 's/^ *//g')

# Engines
case "$ENGINE" in
    yt)
        [[ -z "$QUERY" ]] \
            && xdg-open "https://www.youtube.com/feed/subscriptions" \
            || xdg-open "https://www.youtube.com/results?search_query=$(echo "$QUERY" | sed 's/ /+/g')"
        exit
        ;;
    arch)
        xdg-open "https://wiki.archlinux.org/index.php?search=$(echo "$QUERY" | sed 's/ /+/g')"
        exit
        ;;
    hypr)
        xdg-open "https://wiki.hyprland.org/Getting-Started/$(echo "$QUERY" | sed 's/ /+/g')"
        exit
        ;;
    man)
        [[ -z "$QUERY" ]] && rofi -e "No command specified for man." && exit 1
        kitty -e man "$QUERY" &
        exit
        ;;
    ch)
        if [[ -z "$QUERY" ]]; then
            xdg-open "https://chat.openai.com"
            exit
        fi
        exit
        ;;

    mon)
        if [[ -z "$QUERY" ]]; then
            xdg-open "https://monkeytype.com"
            exit
        fi
        exit
        ;;
    wp)
    if [[ -z "$QUERY" ]]; then
        xdg-open "https://web.whatsapp.com"
        exit
    fi
    exit
    ;;

    re)
        if [[ -z "$QUERY" ]]; then
            xdg-open "https://reddit.com"
            exit
        fi
        exit
        ;;
    ytm)
        if [[ -z "$QUERY" ]]; then
            firefox "https://music.youtube.com"
        else
            firefox "https://music.youtube.com/search?q=$(echo "$QUERY" | sed 's/ /+/g')"
        fi
        exit
        ;;
    nvim)
        if [[ -z "$QUERY" ]]; then
            kitty --class floatterm -e nvim "$HOME" &
        elif [[ -d "$QUERY" ]]; then
            kitty --class floatterm --directory "$QUERY" -e nvim &
        elif [[ -f "$QUERY" ]]; then
            kitty --class floatterm -e nvim "$QUERY" &
        else
            kitty --class floatterm -e nvim "$QUERY" &
        fi
        exit
        ;;

esac

xdg-open "https://www.google.com/search?q=$(echo "$SEARCH_STRING" | sed 's/ /+/g')"
