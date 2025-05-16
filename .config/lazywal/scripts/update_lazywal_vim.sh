#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Update LazyWal-Vim Theme Script
# -----------------------------------------------------------------------------
# Description : Generates a Lua theme file for Neovim based on Pywal colors.
# # location    : ~/.config/lazywal/scripts/update_lazywal_vim.sh
# Requires    : 'jq'
# -----------------------------------------------------------------------------

# Path to wal's colors.json
WAL_COLORS="$HOME/.cache/wal/colors.json"
# Path to the output theme file
DEST="$HOME/.config/nvim/lua/themes/lazywal.lua"

# Create the destination directory if it doesn't exist
mkdir -p "$(dirname "$DEST")"

# Check if the wal colors file exists
if [ ! -f "$WAL_COLORS" ]; then
	echo "Archivo de colores de Pywal no encontrado: $WAL_COLORS" >&2
	exit 1
fi

# Load color variables from 'colors.json'
bg=$(jq -r ".special.background" "$WAL_COLORS")
fg=$(jq -r ".special.foreground" "$WAL_COLORS")

mix_colors() {
	c1="$1"
	c2="$2"
	p="$3"
	r1=$((16#${c1:1:2}))
	g1=$((16#${c1:3:2}))
	b1=$((16#${c1:5:2}))
	r2=$((16#${c2:1:2}))
	g2=$((16#${c2:3:2}))
	b2=$((16#${c2:5:2}))
	mr=$(((r1 * p + r2 * (100 - p)) / 100))
	mg=$(((g1 * p + g2 * (100 - p)) / 100))
	mb=$(((b1 * p + b2 * (100 - p)) / 100))
	printf "#%02x%02x%02x" $mr $mg $mb
}

lum() {
	c="$1"
	r=$((16#${c:1:2}))
	g=$((16#${c:3:2}))
	b=$((16#${c:5:2}))
	echo $(((r * 299 + g * 587 + b * 114) / 1000))
}
bg_lum=$(lum "$bg")
fg_lum=$(lum "$fg")
if [ "$bg_lum" -lt 80 ] && [ "$fg_lum" -lt 80 ]; then
	fg=$(mix_colors "$fg" "#ffffff" 70)
elif [ "$bg_lum" -gt 175 ] && [ "$fg_lum" -gt 175 ]; then
	fg=$(mix_colors "$fg" "#000000" 70)
fi

blue_base=$(jq -r ".colors.color4" "$WAL_COLORS")

blue1=$(mix_colors "$blue_base" "#ffffff" 80)
blue2=$(mix_colors "$blue_base" "#ffffff" 60)
blue3=$(mix_colors "$blue_base" "#ffffff" 40)
blue4="$blue_base"
blue5=$(mix_colors "$blue_base" "#000000" 35)
blue5=$(mix_colors "$blue_base" "#ffffff" 80)
blue6=$(mix_colors "$blue_base" "#000000" 80)
blue7=$(mix_colors "$blue_base" "#000000" 60)

# Extra colors
red=$(jq -r ".colors.color1" "$WAL_COLORS")
red1=$(mix_colors "$red" "#000000" 30)

green=$(jq -r ".colors.color2" "$WAL_COLORS")
green1=$(mix_colors "$green" "#ffffff" 20)
green2=$(mix_colors "$green" "$blue4" 50)

yellow=$(jq -r ".colors.color3" "$WAL_COLORS")
orange=$(mix_colors "$yellow" "$red" 50)

purple=$(jq -r ".colors.color5" "$WAL_COLORS")
magenta=$(mix_colors "$purple" "#ffffff" 20)
magenta2=$(mix_colors "$purple" "$red" 60)

cyan=$(jq -r ".colors.color6" "$WAL_COLORS")
teal=$(mix_colors "$cyan" "$green" 50)

dark3=$(mix_colors "$bg" "$fg" 20)
dark5=$(mix_colors "$bg" "$fg" 40)

fg_dark=$(mix_colors "$fg" "$bg" 40)
fg_gutter=$(mix_colors "$fg" "$magenta2" 50)
bg_dark=$(mix_colors "$bg" "#000000" 60)
bg_dark1=$(mix_colors "$bg" "#000000" 80)
bg_highlight=$(mix_colors "$bg" "$red1" 50)
comment=$(jq -r ".special.foreground" "$WAL_COLORS")
terminal_black=$(mix_colors "$bg" "#ffffff" 80)

git_add=$(jq -r ".colors.color10" "$WAL_COLORS")
git_change=$(jq -r ".colors.color11" "$WAL_COLORS")
git_delete=$(jq -r ".colors.color9" "$WAL_COLORS")

# Escribir archivo Lua
cat >"$DEST" <<EOF
return {
    bg = "${bg}",
    bg_dark = "${bg_dark}",
    bg_dark1 = "${bg_dark1}",
    bg_highlight = "${bg_highlight}",
    blue = "${blue4}",
    blue0 = "${blue3}",
    blue1 = "${blue1}",
    blue2 = "${blue2}",
    blue5 = "${blue5}",
    blue6 = "${blue6}",
    blue7 = "${blue7}",
    comment = "${comment}",
    cyan = "${cyan}",
    dark3 = "${dark3}",
    dark5 = "${dark5}",
    fg = "${fg}",
    fg_dark = "${fg_dark}",
    fg_gutter = "${fg_gutter}",
    green = "${green}",
    green1 = "${green1}",
    green2 = "${green2}",
    magenta = "${magenta}",
    magenta2 = "${magenta2}",
    orange = "${orange}",
    purple = "${purple}",
    red = "${red}",
    red1 = "${red1}",
    teal = "${teal}",
    terminal_black = "${terminal_black}",
    yellow = "${yellow}",
    git = {
        add = "${git_add}",
        change = "${git_change}",
        delete = "${git_delete}",
    },
}
EOF
