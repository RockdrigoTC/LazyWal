#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# LazyWal Setup Script
# -----------------------------------------------------------------------------
# Description : Automated installer and configurator for the LazyWal environment.
# Requirements: Arch Linux
# Usage       : It is highly recommended to run this script on a fresh system.
# Notes       : This script expects the repository to be cloned locally to preserve
#               file permissions and ensure correct operation.
#               Execute the script from the cloned repository directory.
#               This script requires sudo access.
# -----------------------------------------------------------------------------

# --- Load functions ---
source ./.config/lazywal/scripts/functions.sh

[ ! -f "Extras/IUseArch.BTW" ] && {
	error "Error: Please run this script from the root of the cloned repository." --log
	sleep 3
	exit 1
}

info "Welcome to the LazyWal Setup!"
sleep 2
warn "This script requires sudo. Please do not leave your desk while it runs."
sleep 5

info "Performing a full system update..." --log
sudo pacman --noconfirm -Syu
success "System update done." --log
sleep 2

info "Installing git and essential base-devel tools..."
sudo pacman -S --noconfirm --needed git base-devel fakeroot || {
	error "Failed to install git and base-devel." --log
	sleep 3
	exit 1
}
success "Git and base-devel installed." --log

warn "Checking for AUR helper (Paru)..."
sleep 2
if ! command -v paru &>/dev/null; then
	info "Installing Paru (AUR helper)..."
	mkdir -p "$HOME"/.srcs
	git clone https://aur.archlinux.org/paru-bin.git "$HOME"/.srcs/paru-bin
	cd "$HOME"/.srcs/paru-bin && run_command "makepkg -si --noconfirm"
	# Temporary fix for paru-bin
	sudo ln -sf /usr/lib/libalpm.so.15.0.0 /usr/lib/libalpm.so.14 >/dev/null 2>&1
	success "Paru installed successfully." --log
else
	success "Paru is already installed."
fi

info "Installing dependencies. This may take a while..."
sleep 2

info "Installing system packages..."
paru -S --noconfirm --needed \
	meson uthash bc wget curl xclip networkmanager openssh \
	nodejs npm python-pynvim python-psutil luarocks pastel \
	xorg-server qtile xsettingsd dunst zsh ly neofetch pfetch htop \
	alacritty feh flameshot imagemagick betterlockscreen crudini \
	pulsemixer playerctl brightnessctl cava libconfig jq mousepad \
	thunar ranger ueberzug python-pdftotext rofi rofi-greenclip \
	wpgtk python-pywalfox fzf fd ripgrep lazygit bat lsd pacseek \
	neovim vim nano nano-syntax-highlighting python-pulsectl-asyncio \
	papirus-icon-theme gtk-engine-murrine btop bluez-utils firefox || {
	error "Failed to install system packages." --log
	sleep 3
	exit 1
}

success "System packages installed." --log

# Install configuration files
info "Installing configuration files..." --log
sleep 2

for dir in alacritty btop cava dunst lazywal picom qtile ranger rofi; do
	cp -rf ./.config/$dir "$HOME"/.config/
done

cp -rf ./Themes "$HOME"/
cp -f ./Extras/.xsettingsd "$HOME"/
cp -f ./Extras/.nanorc "$HOME"/
success "Configurations installed." --log
sleep 2

# Detect GPU and suggest driver
info "Detecting GPU..." --log
gpu=$(lspci | grep -iE 'vga|3d')
driver=""
default=4
echo "$gpu" | grep -qi nvidia && driver="nvidia nvidia-settings nvidia-utils" && default=3
echo "$gpu" | grep -qi amd && driver="xf86-video-amdgpu" && default=2
echo "$gpu" | grep -qi intel && driver="xf86-video-intel" && default=1

echo "Detected GPU: $gpu"
echo "Suggested driver: ${driver:-none}"
echo "1) Intel  2) AMD  3) NVIDIA  4) Skip"

read -r -p "Choose your video driver (default $default): " choice

# Process choice
case "$choice" in
1) dri="xf86-video-intel" ;;
2) dri="xf86-video-amdgpu" ;;
3) dri="nvidia nvidia-settings nvidia-utils" ;;
4 | "") dri="$driver" ;;
*)
	warn "Invalid option, using suggested driver: $driver."
	dri="$driver"
	;;
esac

info "Installing display drivers and Xorg..."
paru -S --noconfirm --needed xorg xorg-xinit xf86-input-libinput $dri || {
	error "Failed to install display drivers." --log
	sleep 3
	exit 1
}
success "Display drivers installed." --log

# Install fonts
info "Installing fonts..."
mkdir -p "$HOME"/.local/share/fonts
cp -rf ./fonts/* "$HOME"/.local/share/fonts/
fc-cache -f >/dev/null 2>&1
success "Fonts installed successfully."

# Installing picom
if ! command -v picom &>/dev/null; then
	[ -d ./picom ] && rm -rf ./picom >/dev/null 2>&1

	info "Installing Picom" --log
	git clone https://github.com/jonaburg/picom

	(
		cd ./picom || exit 1
		meson --buildtype=release . build
		ninja -C build
		sudo ninja -C build install
	)

	rm -rf picom >/dev/null 2>&1
else
	info "Picom is already installed. Skipping installation." --log
fi

# Set Zsh as the default shell
info "Setting Zsh as the default shell..." --log
chsh -s "$(which zsh)"

# Install Oh My Zsh Powerlevel10k and plugins
if [ -d "$HOME/.oh-my-zsh" ]; then
	rm -rf "$HOME"/.oh-my-zsh
fi

info "Installing Oh My Zsh and plugins..." --log
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

info "Waiting for Oh My Zsh to install..."
for _ in {1..30}; do [ -d "$HOME/.oh-my-zsh" ] && break || sleep 1; done
[ -d "$HOME/.oh-my-zsh" ] || {
	error "Failed to install Oh My Zsh." --log
	sleep 3
	exit 1
}

info "Installing zsh plugins..." --log
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}/themes/powerlevel10k"

cp -f ./Extras/.zshrc "$HOME"/.zshrc
cp -f ./Extras/.p10k.zsh "$HOME"/.p10k.zsh
success "Zsh plugins installed." --log

# Installing LazyVim
info "Installing LazyVim..." --log
[ -d "$HOME"/.config/nvim ] && rm -rf "$HOME"/.config/nvim
git clone https://github.com/LazyVim/starter $HOME/.config/nvim
cp -rf ./.config/nvim/lua/themes "$HOME"/.config/nvim/lua/themes
cp -f ./.config/nvim/lua/plugins/colorscheme.lua "$HOME"/.config/nvim/lua/plugins/colorscheme.lua
rm -rf "$HOME"/.config/nvim/.git
success "LazyVim installed." --log

# Enable betterlockscreen
info "Enabling betterlockscreen" --log
systemctl enable betterlockscreen
betterlockscreen -u "$HOME"/Themes/RockArch/RockArch.jpg >/dev/null 2>&1
sleep 1

# Config ly
info "Setting up ly..."
sudo cp -f ./Extras/config.ini.ly /etc/ly/config.ini
info "Enabling ly to start on boot..."
sudo systemctl enable ly
sleep 1

# Config btop
BTOP_CONFIG_DIR="$HOME"/.config/btop
BTOP_THEME_PATH="$BTOP_CONFIG_DIR"/themes/lazywal.theme
sed -i "s|^color_theme = .*|color_theme = \"$BTOP_THEME_PATH\"|" "$BTOP_CONFIG_DIR"/btop.conf

# Enabling extras services
sudo systemctl enable NetworkManager.service
systemctl --user enable greenclip.service
sleep 1

# Spotify theme script (post-install)
mkdir -p ~/.local/bin
cp -rf "./Extras/spotify-setup" "$HOME"/.local/bin/spotify-setup

# Generate colorscheme
info "Pre-generating colors scheme..." --log
info "Might take some time, hang on tight!"
wpg -a "$HOME"/Themes/Berserk/Berserk.jpg >/dev/null 2>&1
success "Theme Berserk ../done"
wpg -a "$HOME"/Themes/Ocean/Ocean.jpg >/dev/null 2>&1
success "Theme Ocean ../done"
wpg -a "$HOME"/Themes/Sky/Sky.jpg >/dev/null 2>&1
success "Theme Sky ../done"
wpg -a "$HOME"/Themes/RockArch/RockArch.jpg >/dev/null 2>&1
success "Theme RockArch ../done"

echo ""
success "All themes generated successfully!" --log

# Config wpgtk
echo "Configuring wpgtk..." --log
mkdir -p "$HOME"/.local/share/themes
mkdir -p "$HOME"/.themes
mkdir -p "$HOME"/.config/wpg/templates

cp -f ./.config/wpg/wpg.conf "$HOME"/.config/wpg/wpg.conf
git clone https://github.com/deviantfero/wpgtk-templates.git /tmp/wpgtk-templates
cp -rf /tmp/wpgtk-templates/FlatColor "$HOME"/.local/share/themes/FlatColor
ln -sf "$HOME"/.local/share/themes/FlatColor "$HOME"/.themes/FlatColor

wpg --link ./Extras/templates/gtk2.base "$HOME"/.local/share/themes/FlatColor/gtk-2.0/gtkrc
wpg --link ./Extras/templates/gtk3.0.base "$HOME"/.local/share/themes/FlatColor/gtk-3.0/gtk.css
wpg --link ./Extras/templates/gtk3.20.base "$HOME"/.local/share/themes/FlatColor/gtk-3.20/gtk.css
wpg --link ./Extras/templates/alacritty_colors.toml.base "$HOME"/.config/alacritty/colors.toml
wpg --link ./Extras/templates/qtilecolors.py.base "$HOME"/.config/qtile/qtilecolors.py
wpg --link ./Extras/templates/dunstrc.base "$HOME"/.config/dunst/dunstrc
wpg --link ./Extras/templates/btop_lazywal.theme.base "$HOME"/.config/btop/themes/lazywal.theme
wpg --link ./Extras/templates/cava_config.base "$HOME"/.config/cava/config
wpg --link ./Extras/templates/rofi_colors.rasi.base "$HOME"/.config/rofi/settings/rofi_colors.rasi

success "wpgtk configured." --log

# Set default theme
info "Setting LazyWal as default theme..."
wpg -s "LazyWal.png" >/dev/null 2>&1
info "Updating colors..."
./.config/lazywal/scripts/update_colors.sh >/dev/null 2>&1
success "Default theme set to LazyWal." --log

echo ""
success "Installation is complete!" --log
warn "Please restart your system to apply the changes."

# Restart the system
read -r -p "Restart Now? [Y/n]: " confirm
[[ $confirm =~ ^[Nn]$ ]] || sudo reboot
