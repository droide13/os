#!/bin/bash

echo "🔧 Updating system..."
sudo pacman -Syu --noconfirm

echo "🔧 Installing base packages and dependencies..."
sudo pacman -S --noconfirm \
base-devel git zsh curl wget net-tools unzip \
neofetch htop \
python ruby go nodejs npm \
yay -S --noconfirm \
nmap whois \
wireshark-qt \
python python-pip ruby go nodejs npm


echo "✅ All tools installed successfully!"

echo "💡 Reboot or re-login may be required for group changes to take effect."
