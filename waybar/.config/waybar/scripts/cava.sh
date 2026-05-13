#! /bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]; do
  dict="${dict}s/$i/${bar:$i:1}/g;"
  i=$((i = i + 1))
done

# write cava config
config_file="/tmp/polybar_cava_config"
echo "
[general]
bars = 36

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" >$config_file

cava_pid=""

start_cava() {
  setsid bash -c "cava -p \"$config_file\" | stdbuf -oL sed \"$dict\"" &
  cava_pid=$!
}

stop_cava() {
  if [ -n "$cava_pid" ]; then
    sleep 1
    kill -- -"$cava_pid" 2>/dev/null # negative PID = kill entire process group
    wait "$cava_pid" 2>/dev/null
    cava_pid=""
    echo ""
  fi
}

cleanup() {
  stop_cava
  exit
}
trap cleanup EXIT INT TERM

# Handle initial state on startup
[ "$(playerctl status 2>/dev/null)" = "Playing" ] && start_cava

# Outer loop restarts monitoring if the player process disappears
while true; do
  while read -r status; do
    if [ "$status" = "Playing" ]; then
      [ -z "$cava_pid" ] && start_cava
    else
      stop_cava
    fi
  done < <(playerctl -F status 2>/dev/null)

  # playerctl exited = player closed entirely
  stop_cava
  sleep 1
done
