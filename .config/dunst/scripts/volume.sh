#!/bin/bash

# Obtener el índice del sink por defecto
sink=$(pactl get-default-sink)

# Obtener el volumen actual en porcentaje
volume=$(pactl get-sink-volume "$sink" | awk -F'/' 'NR==1 {gsub(/%| /,"",$2); print $2}')

# Verificar si está muteado
muted=$(pactl get-sink-mute "$sink" | awk '{print $2}')

if [[ "$muted" == "yes" || "$volume" -eq 0 ]]; then
    icon="$HOME/.config/dunst/scripts/assets/volume-mute.svg"
elif [[ "$volume" -lt 100 ]]; then
    icon="$HOME/.config/dunst/scripts/assets/volume-normal.svg"
else
    icon="$HOME/.config/dunst/scripts/assets/volume-max.svg"
fi

dunstify -a "volume" -i "$icon" -r 3456 -h int:value:"$volume" "Volume: ${volume}%"
