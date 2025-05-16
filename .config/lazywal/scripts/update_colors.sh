#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Update Colors Script
# -----------------------------------------------------------------------------
# Description : Applies wal colors to desktop components and CLI tools.
# location    : ~/.config/lazywal/scripts/update_colors.sh
# Requires    : 'jq', 'imagemagick', 'sed', 'wal', 'functions.sh'
# Note        : This script is intended to be run after 'change_theme.sh'
# -----------------------------------------------------------------------------

# --- Paths ---
WAL_JSON="$HOME/.cache/wal/colors.json"
ROFI_IMG_DIR="$HOME/.config/rofi/images"
QTILE_LAYOUT_DIR="$HOME/.config/qtile/Assets/layout"
QTILE_BATTERY_DIR="$HOME/.config/qtile/Assets/battery"
P10K_CONFIG="$HOME/.p10k.zsh"

# --- Functions ---

get_wal_value() {
    jq -r "$1" "$WAL_JSON"
}

generate_rofi_image() {
    local crop_size="$1"
    local output_file="$2"
    magick "$wallpaper_path" -gravity center -crop "$crop_size" +repage -blur 0x8 \
        -fill "rgba(0,0,0,0.5)" -colorize 50 "$output_file"
}

recolor_qtile_assets() {
    local src_dir="$1"
    local dest_dir="$2"
    local color="$3"
    for img in "$src_dir"/*.png; do
        magick "$img" -fill "$color" -colorize 100% "$dest_dir/$(basename "$img")"
    done
}

update_p10k_colors() {
    declare -A p10k_colors=(
        [POWERLEVEL9K_OS_ICON_FOREGROUND]="$highlight"
        [POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND]="$accent"
        [POWERLEVEL9K_DIR_FOREGROUND]="$accent"
        [POWERLEVEL9K_DIR_SHORTENED_FOREGROUND]="$secondary"
        [POWERLEVEL9K_DIR_ANCHOR_FOREGROUND]="$highlight"
        [POWERLEVEL9K_STATUS_OK_FOREGROUND]="$primary"
        [POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND]="$primary"
    )
    for var in "${!p10k_colors[@]}"; do
        sed -i "s|^[[:space:]]*typeset -g $var=.*|  typeset -g $var='${p10k_colors[$var]}'|" "$P10K_CONFIG"
    done
}

# --- Main Process ---

primary=$(get_wal_value '.colors.color12')
secondary=$(get_wal_value '.colors.color5')
accent=$(get_wal_value '.colors.color1')
highlight=$(get_wal_value '.colors.color3')
wallpaper_path=$(get_wal_value '.wallpaper')

# Rofi overlays
mkdir -p "$ROFI_IMG_DIR"
generate_rofi_image "800x600+0+0" "$ROFI_IMG_DIR/launcher.png"
generate_rofi_image "1200x600+0+0" "$ROFI_IMG_DIR/power.png"

# Qtile bar assets
recolor_qtile_assets "$QTILE_LAYOUT_DIR/default" "$QTILE_LAYOUT_DIR" "$secondary"
recolor_qtile_assets "$QTILE_BATTERY_DIR/default" "$QTILE_BATTERY_DIR" "$primary"
cp -f "$QTILE_BATTERY_DIR/default/battery-missing.png" "$QTILE_BATTERY_DIR/battery-missing.png"

# Powerlevel10k config
update_p10k_colors

# LazyVim color update
"$HOME/.config/lazywal/scripts/update_lazywal_vim.sh"
