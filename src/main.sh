#!/bin/zsh

# Customize thresholds (in days)
modified_within_days=1
stale_after_days=7
target_dir="${1:-.}"

print_color() {
  local color=$1 text=$2
  case $color in
    green)  print -P "%F{green}$text%f" ;;
    red)    print -P "%F{red}$text%f" ;;
    blue)   print -P "%F{blue}$text%f" ;;
    white)  print -P "%F{white}$text%f" ;;
  esac
}

for dir in "$target_dir"/*(/); do
  latest=$(find "$dir" -type f -printf "%T@\n" 2>/dev/null | sort -nr | head -n 1)
  now=$(date +%s)
  if [[ -z "$latest" ]]; then
    print_color white "${dir:t}/ (empty or no files)"
    continue
  fi
  delta_days=$(( (now - ${latest%.*}) / 86400 ))

  if (( delta_days <= modified_within_days )); then
    print_color green "${dir:t}/"
  elif (( delta_days > stale_after_days )); then
    print_color blue "${dir:t}/"
  else
    print_color white "${dir:t}/"
  fi
done
