#--------------------------------------------------------------------------------
#                                                                              
#  ,------.                                 ,--.   ,--.                        
#  |  .--. ' ,---. ,--.   ,--. ,---. ,--.--.|   `.'   | ,---. ,--,--, ,--.,--. 
#  |  '--' || .-. ||  |.'.|  || .-. :|  .--'|  |'.'|  || .-. :|      \|  ||  | 
#  |  | --' ' '-' '|   .'.   |\   --.|  |   |  |   |  |\   --.|  ||  |'  ''  ' 
#  `--'      `---' '--'   '--' `----'`--'   `--'   `--' `----'`--''--' `----'  
#
#
#
#      , _ ,       RESUME: powermenu script to suspend, lock, reboot & shutdown
#     ( o o )             
#    /'` ' `'\     AUTHOR:  Andr3xDev
#    |'''''''|     URL:  https://github.com/Andr3xDev/Dotfiles
#    |\\'''//|      
#       """        ORIGINAL AUTHOR:  adi1090x                                 
#                  URL: https://github.com/adi1090x/rofi
#
#--------------------------------------------------------------------------------



#--------------------------------------------------------------------------------
#    Variables & elements
#--------------------------------------------------------------------------------

# Current Theme
dir="$HOME/.config/rofi/powermenu/"
theme='style'

# CMDs
lastlogin="`last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7`"
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

# Options
shutdown='󰐥'
reboot='󰜉'
lock='󰌾'
suspend=''
yes=''
no=''



#--------------------------------------------------------------------------------
#    CMD // Promps
#--------------------------------------------------------------------------------

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "⏱ Uptime: $uptime" \
		-mesg "⏱ Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 215px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}



#--------------------------------------------------------------------------------
#    Screen options // Runners
#--------------------------------------------------------------------------------

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass options to menu
run_rofi() {
	echo -e "$suspend\n$shutdown\n$reboot\n$lock" | rofi_cmd
}

# Execute option command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
            loginctl lock-sesion
		fi
	else
		exit 0
	fi
}



#--------------------------------------------------------------------------------
#    Actions to each option
#--------------------------------------------------------------------------------

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $lock)
	    hyprlock
        ;;
    $suspend)
		run_cmd --suspend
        ;;
esac
