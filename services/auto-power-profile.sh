#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0"  # or BAT1, check yours
AC_PATH="/sys/class/power_supply/AC"

# Wait for power-profiles-daemon to be fully ready
for i in {1..10}; do
    powerprofilesctl list &>/dev/null && break
    sleep 2
done

AC_ONLINE=$(cat "$AC_PATH/online")
CAPACITY=$(cat "$BATTERY_PATH/capacity")

if [[ "$AC_ONLINE" == "1" ]]; then
	powerprofilesctl set performance
elif [[ "$CAPACITY" -le 30 ]]; then
	powerprofilesctl set power-saver
elif [[ "$CAPACITY" -le 80 ]] then
	powerprofilesctl set balanced
else
	powerprofilesctl set balanced
fi
