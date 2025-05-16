#!/bin/bash

# -----------------------------------------------------------------------------
# Show Help Script
# -----------------------------------------------------------------------------
# Description : Displays the help file in a rofi menu with search functionality.
# location    : ~/.config/lazywal/scripts/show_help.sh
# Requires    : 'rofi'
# -----------------------------------------------------------------------------

# Ruta del archivo de ayuda
HELP_FILE="$HOME/.config/lazywal/help.txt"

# Mostrar el archivo en Rofi con búsqueda
rofi -dmenu \
	-i \
	-p "Keybind Search > " \
	-theme ~/.config/rofi/settings/help_menu.rasi <"$HELP_FILE"
