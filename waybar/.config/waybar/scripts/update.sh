#! /bin/bash

sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

echo -e "\e[1;33mSystem update complete!\e[0m"
echo -e "\e[1;32m>> Press any key to continue...\e[0m"
read -rp "" -n1 -s
exit 0
