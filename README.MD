# LazyWal - Arch Linux Ricing Setup Script

---

<p align="center">
  <img src="screenshots/LazyWal.gif" alt="LazyWal Theme" width="600"/>
</p>

<p align="center">
  <img src="screenshots/Forest.gif" alt="Forest Theme" width="280" style="margin:10px"/>
  <img src="screenshots/Sky.gif" alt="Sky Theme" width="280" style="margin:10px"/><br>
  <img src="screenshots/Ocean.gif" alt="Ocean Theme" width="280" style="margin:10px"/>
  <img src="screenshots/RockArch.gif" alt="RockArch Theme" width="280" style="margin:10px"/>
</p>

> **Automated installer & theme manager for Arch-based systems.**
> Minimal and efficient

---

## Table of Contents

- [About LazyWal](#about-lazywal)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## About LazyWal

**LazyWal** is a shell script to automate the installation and configuration of a personalized ricing environment on Arch Linux.
It integrates **Pywal**, **wpgtk**, **Qtile**, **Zsh**, and many more tools to provide a cohesive visual and functional experience.

The goal is to simplify the process of setting up a beautiful and productive desktop, while keeping it modular and easy to customize.

---

## Features

- 🔹 Automatic installation of AUR helper (`paru`).
- 🔹 Configures Qtile, Dunst, Rofi, Alacritty, etc.
- 🔹 Installs Oh My Zsh, Powerlevel10k, plugins.
- 🔹 Applies pywal themes & gtk themes.
- 🔹 Fonts, Picom (jonaburg fork), and utilities setup.
- 🔹 GPU driver detection & suggestion.
- 🔹 Optional Spotify theming script.
- 🔹 Modular structure for easy customization.

---

## Installation

### Clone the repository
```bash
git clone https://github.com/RockdrigoTC/LazyWal.git
cd LazyWal
