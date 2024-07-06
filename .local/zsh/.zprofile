[[ -d $HOME/.cache/awesome/last-tag ]] && rm -rf $HOME/.cache/awesome/last-tag &>/dev/null
[[ -d $HOME/.cache/awesome/last-pos ]] && rm -rf $HOME/.cache/awesome/last-pos &>/dev/null
if [[ $TTY == "/dev/tty1" ]]; then
	if cat /etc/X11/xinit/xinitrc | grep 'exec hyperland' ; then
		Hyprland
	else
		startx
	fi
else
	if [[ ! -z $SSH_TTY ]]; then 
		tty='true'
	else
		tty='true'
	fi
fi
