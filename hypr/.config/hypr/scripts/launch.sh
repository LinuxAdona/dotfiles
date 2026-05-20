#!/bin/bash

pkill waybar
pkill swaync
pkill cava

/usr/bin/waybar &
swaync &
hyprctl reload
