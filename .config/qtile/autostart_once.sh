#!/bin/env bash

# -----------------------------------------------------------------------------
# Autostart Script for Qtile
# -----------------------------------------------------------------------------
# Description : This script is executed once at the start of Qtile.
# location    : ~/.config/qtile/autostart_once.sh
# Requires    : 'dunstify', 'xsettingsd', 'picom', 'betterlockscreen', 'wpg', 'setxkbmap'
# -----------------------------------------------------------------------------

# Setup monitors
"$HOME"/.config/qtile/setup_monitors.sh

# Apply wallpaper using wpg (pywal)
"$HOME"/.config/wpg/wp_init.sh

# Config keyboard
current=$(setxkbmap -query | awk '/layout:/ {print $2}')
if [[ ! $current =~ ^(es|us)$ ]]; then
	lang=${LANG:0:2}
	[[ $lang == en ]] && lang=us
	setxkbmap "$lang"
fi

# Start xsettingsd (GTK live update)
xsettingsd &

# Start greenclip (clipboard manager)
systemctl --user start greenclip.service

# Start picom
picom --config ~/.config/picom/picom.conf --experimental-backends &

dunstify "Welcome $USER!" \
	--appname "$(uname -n)" \
	--urgency low \
	--timeout 5 \
	--replace
