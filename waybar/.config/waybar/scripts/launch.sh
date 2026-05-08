#!/bin/bash

pkill waybar
pkill swaync

/usr/bin/waybar &
swaync &
