#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Bash Functions for LazyWal
# -----------------------------------------------------------------------------
# Description : Functions for LazyWal theme management and color validation.
# location    : ~/.config/lazywal/scripts/functions.sh
# Requires    : 'jq', 'dunstify', 'sed'
# -----------------------------------------------------------------------------

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/lazywal/lazywal.log"
PKG_MANAGER="paru"

if [[ -t 1 ]]; then
	BLUE="\e[34m"
	GREEN="\e[32m"
	RED="\e[31m"
	YELLOW="\e[33m"
	RESET="\e[0m"
else
	BLUE=""
	GREEN=""
	RED=""
	YELLOW=""
	RESET=""
fi

log_msg() {
	local level="$1"
	local msg="${2:-}"
	mkdir -p "$(dirname "$LOG_FILE")"
	[ -e "$LOG_FILE" ] || touch "$LOG_FILE"
	echo "[$(date '+%F %T')] $level $msg" >>"$LOG_FILE"
}

log_pipe() {
	local level="${1:-INFO}"
	while IFS= read -r line; do
		log_msg "[$level]" "$line"
	done
}

info() {
	local msg="$1"
	local flag="${2:-}"
	echo -e "${BLUE}[INFO]${RESET}  $msg"
	[[ "$flag" == "--log" ]] && log_msg "[LazyWal] [INFO]" "$msg"
}

success() {
	local msg="$1"
	local flag="${2:-}"
	echo -e "${GREEN}[OK]${RESET}    $msg"
	[[ "$flag" == "--log" ]] && log_msg "[LazyWal] [OK]" "$msg"
}

warn() {
	local msg="$1"
	local flag="${2:-}"
	echo -e "${YELLOW}[WARN]${RESET}  $msg"
	[[ "$flag" == "--log" ]] && log_msg "[LazyWal] [WARN]" "$msg"
}

error() {
	local msg="$1"
	local flag="${2:-}"
	echo -e "${RED}[FAIL]${RESET}  $msg"
	[[ "$flag" == "--log" ]] && log_msg "[LazyWal] [FAIL]" "$msg"
}

restart_and_check() {
	killall "$1" >/dev/null 2>&1
	"$1" >/dev/null 2>&1 &
	pid=$!
	for _ in {1..7}; do ps -p $pid >/dev/null && {
		success "$1 Updated" --log
		return
	} || sleep 0.2; done
	dunstify -u normal "$1 Updated" "Failed to restart $1"
	error "Failed to restart $1" --log
	exit 1
}

validate_color_json() {
	local json_file="$1"
	local json_name
	json_name="$(basename "$json_file")"

	info "Found color scheme file: $json_name. Validating content..."
	if [[ ! -s "$json_file" ]] || ! jq '.' "$json_file" >/dev/null 2>&1; then
		error "$json_name is either empty or malformed" --log
		return 1
	fi

	local keys
	for i in {0..15}; do keys+=("colors.color$i"); done

	local hex_color_regex='^#[0-9a-fA-F]{6}$'

	for key in "${keys[@]}"; do
		value=$(jq -r ".$key // empty" "$json_file")
		if [[ -z "$value" || ! "$value" =~ $hex_color_regex ]]; then
			error "Invalid or missing value for '$key': '$value' in $json_name" --log
			return 1
		fi
	done

	success "$json_name color scheme is valid." --log
	return 0
}

install_pkg() {
	local pkg="$1"
	local bin="$2"

	info "Checking installation for $pkg"
	if ! command -v "$bin" &>/dev/null; then
		info "Installing $pkg"
		if $PKG_MANAGER -S --noconfirm "$pkg" >/dev/null 2>&1; then
			success "$pkg installed successfully" --log
		else
			error "Failed to install $pkg." --log
			exit 1
		fi
	else
		info "$pkg already installed" --log
	fi
}
