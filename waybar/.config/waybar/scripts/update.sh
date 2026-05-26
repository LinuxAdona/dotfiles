#! /bin/bash

sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

echo "System update complete!"
read -rp ">> Press any key to continue..." -n1 -s
exit 0
