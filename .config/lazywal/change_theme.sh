#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Change Theme Script
# -----------------------------------------------------------------------------
# Location  : ~/.config/lazywal/change_theme.sh
# Requires  : 'betterlockscreen', 'wpg', 'spicetify', 'dunstify', 'jq', 'sed'
# Note      : Review the log file for detailed error messages and status.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Load functions and check arguments
# -----------------------------------------------------------------------------
source "$HOME"/.config/lazywal/scripts/functions.sh

# Check if the theme name is provided
if [[ -z "$1" ]]; then
	dunstify -u normal -t 5000 "No themes available" "Please provide a theme name."
	error "No theme name provided." --log
	exit 1
fi

theme_name="$1"
theme_dir="$HOME/Themes/$theme_name"
theme_json="$theme_dir/$theme_name.json"

# -----------------------------------------------------------------------------
# Check if the theme directory exists and locate wallpaper
# -----------------------------------------------------------------------------
info "Checking theme directory and wallpaper"
if [[ ! -d "$theme_dir" ]]; then
	dunstify -u normal -t 5000 "Theme not found" "The '$theme_name' directory does not exist."
	error "Theme directory '$theme_dir' does not exist." --log
	exit 1
fi

info "Theme: $theme_name"

# Find wallpaper
wallpaper_path=$(find "$theme_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) | head -n 1)

# Validate wallpaper
if [[ -z "$wallpaper_path" ]]; then
	dunstify -u normal -t 5000 "No image found" "No valid image found in '$theme_dir'."
	error "No valid image found in '$theme_dir'." --log
	exit 1
fi

mime=$(file --mime-type -b "$wallpaper_path")
if [[ $mime != image/* ]]; then
	dunstify -u normal -t 5000 "Invalid image" "The file '$wallpaper_path' is not a valid image."
	error "The file '$wallpaper_path' is not a valid image." --log
	exit 1
fi

wallpaper_name=$(basename "$wallpaper_path")
info "Wallpaper: $wallpaper_name"

# -----------------------------------------------------------------------------
# Apply wallpaper, lockscreen and color scheme
# -----------------------------------------------------------------------------
info "Applying wallpaper and lockscreen"
(betterlockscreen -u "$wallpaper_path" >/dev/null 2>&1) &

# Color scheme: from JSON or generate
if [[ -f "$theme_json" ]] && validate_color_json "$theme_json"; then
	info "Applying color scheme from JSON: $(basename "$theme_json")"
	if ! wpg -i "$wallpaper_name" "$theme_json" 2>&1 | log_pipe "WPG" || ! wpg -s "$wallpaper_name" 2>&1 | log_pipe "WPG"; then
		dunstify -u normal "Error" "Failed to set color scheme with wpg."
		error "Failed to set wallpaper with wpg." --log
		exit 1
	fi
else
	info "Generating color scheme from $wallpaper_name"
	if ! wpg -a "$wallpaper_path" 2>&1 | log_pipe "WPG" || ! wpg -s "$wallpaper_name" 2>&1 | log_pipe "WPG"; then
		dunstify -u normal "Error" "Failed to generate color scheme with wpg."
		error "Failed to generate wallpaper with wpg." --log
		exit 1
	fi
fi

wpg -o "$wallpaper_name" "$theme_json" 2>&1 | log_pipe "WPG"
success "Wallpaper set & color scheme updated" --log

# -----------------------------------------------------------------------------
# Apply system theme changes (GTK, Spotify, assets, Qtile, Dunst)
# -----------------------------------------------------------------------------
info "Reloading system components and themes"

# Reload xsettingsd (GTK live update)
restart_and_check xsettingsd

# Update Spotify theme (remove # comments)
sed -i 's/#//g' "$HOME/.config/spicetify/Themes/text/color.ini"
if pgrep -x "spotify" >/dev/null; then
	(spicetify apply 2>&1 | log_pipe "SPICETIFY") &
else
	(spicetify apply -n 2>&1 | log_pipe "SPICETIFY") &
fi

# Update assets for Qtile bar, rofi, zsh, lazyvim
"$HOME"/.config/lazywal/scripts/update_colors.sh 2>&1 | log_pipe "UPDATE_COLORS"

# Restart Qtile config
qtile cmd-obj -o cmd -f reload_config 2>&1 | log_pipe "QTILE"

# Restart Dunst notifications
restart_and_check dunst

success "The theme $theme_name is now active!" --log

# -----------------------------------------------------------------------------
# Notify user
# -----------------------------------------------------------------------------
sleep 1
dunstify "Theme changed" "The theme '$theme_name' is now active!" \
	-u low \
	-t 5000 \
	-i "$wallpaper_path" \
	-r 1000
