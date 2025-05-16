#!/bin/bash

# -----------------------------------------------------------------------------
# Setup Monitors Script
# -----------------------------------------------------------------------------
# Description : This script sets up the monitor configuration.
# location    : ~/.config/qtile/setup_monitors.sh
# Requires    : 'xrandr'
# -----------------------------------------------------------------------------

# Detectar pantalla interna (eDP o LVDS)
INTERNAL=$(xrandr | grep -E " connected primary" | awk '{print $1}')

# Detectar pantalla externa (HDMI, DP, etc.) que esté conectada pero no sea la interna
EXTERNAL=$(xrandr | grep -E " connected" | grep -v "$INTERNAL" | awk '{print $1}')

# Comprobamos si hay pantalla externa
if [ -n "$EXTERNAL" ]; then
	MONOTOR_MODE="dual"

	xrandr \
		--output "$INTERNAL" --auto --pos 0x0 \
		--output "$EXTERNAL" --auto --right-of "$INTERNAL" --primary
else
	MONOTOR_MODE="single"

	xrandr \
		--output "$INTERNAL" --auto --primary \
		$(xrandr | grep " connected" | grep -v "$INTERNAL" | awk '{print "--output", "$1", "--off"}')
fi

export MONOTOR_MODE
