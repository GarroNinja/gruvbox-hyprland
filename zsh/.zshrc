# Remove Powerlevel10k instant prompt block
# We're using Starship now!

ZSH=/usr/share/oh-my-zsh/

# List of plugins used
plugins=( git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

#natural scoll
export LIBINPUT_MODEL_NATURAL_SCROLL=1

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Helpful aliases
alias c='clear' # clear terminal
alias clr='clear && tmux clear-history'
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor
alias zed='zeditor'
alias snvim='sudo -E nvim'
alias za='nohup zathura "$(find . -type f \( -name "*.pdf" -o -name "*.epub" -o -name "*.djvu" -o -name "*.cbz" -o -name "*.cbr" \) | fzf)" >/dev/null 2>&1 & disown; exit'

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# Display Pokemon and nitch++ side-by-side outside Zed, VSCode, etc.
if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "Code" && "$TERM_PROGRAM" != "Zed" && "$TERM" != "xterm-256color" ]]; then
  printf ""

  MAX_ALLOWED_WIDTH=36
  POKEMON_FILE=$(mktemp)
  found_valid_pokemon=false

  for attempt in {1..5}; do
    pokemon-colorscripts --no-title -r 1,2,3,4,6 > "$POKEMON_FILE"

    # Check Pokémon width using Python
    python3 - "$POKEMON_FILE" "$MAX_ALLOWED_WIDTH" <<'EOF'
import sys, re
filename = sys.argv[1]
max_width = int(sys.argv[2])

with open(filename, encoding="utf-8", errors="ignore") as f:
    lines = f.read().splitlines()

ansi_strip = lambda s: re.sub(r"\x1b\[[0-9;]*[mKHGJ]", "", s)
if all(len(ansi_strip(line)) <= max_width for line in lines):
    sys.exit(0)  # valid
sys.exit(1)  # too wide
EOF

    if [[ $? -eq 0 ]]; then
      found_valid_pokemon=true
      break
    fi
  done

  if ! $found_valid_pokemon; then
    echo "Pokemon too wide!" > "$POKEMON_FILE"
  fi

  NITCH_FILE=$(mktemp)
  nitch++ > "$NITCH_FILE"

  python3 - "$POKEMON_FILE" "$NITCH_FILE" <<'EOF'
import sys, re

with open(sys.argv[1], encoding="utf-8", errors="ignore") as f:
    pokemon_lines = f.read().splitlines()

with open(sys.argv[2], encoding="utf-8", errors="ignore") as f:
    nitch_lines = f.read().splitlines()[4:]  # Skip nitch++ header

strip_ansi = lambda s: re.sub(r"\x1b\[[0-9;]*[mKHGJ]", "", s)
pad = max(len(strip_ansi(line)) for line in pokemon_lines)
max_lines = max(len(pokemon_lines), len(nitch_lines))

for i in range(max_lines):
    left = pokemon_lines[i] if i < len(pokemon_lines) else ""
    right = nitch_lines[i] if i < len(nitch_lines) else ""
    print(f"{left}\033[0m{' ' * (pad - len(strip_ansi(left)))}{right}")
EOF

  rm -f "$POKEMON_FILE" "$NITCH_FILE"
fi

export BROWSER=firefox
export XDG_DEFAULT_BROWSER=firefox

export GTK_IM_MODULE=wayland

# pnpm
export PNPM_HOME="/home/garro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH=$HOME/go/bin:$PATH
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
export XDG_SESSION_TYPE=wayland
export GDK_SCALE=1
export GDK_DPI_SCALE=1.25   # or 1.5 or 2 depending on your monitor
export XCURSOR_SIZE=16
# Initialize Starship prompt
eval "$(starship init zsh)"
