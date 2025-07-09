#!/bin/bash

# Thresholds (in days)
level_1_age_in_days=1
level_1_color="green"
level_2_age_in_days=3
level_2_color="yellow"
level_3_age_in_days=7
level_3_color="red"
target_dir="${1:-.}"

print_color() {
  local color=$1
  local text=$2
  case $color in
  green) echo -e "\033[0;32m$text\033[0m" ;;
  yellow) echo -e "\033[1;33m$text\033[0m" ;;
  red) echo -e "\033[0;31m$text\033[0m" ;;
  white) echo -e "\033[1;37m$text\033[0m" ;;
  blue) echo -e "\033[0;34m$text\033[0m" ;;
  *) echo "$text" ;;
  esac
}

shopt -s nullglob
for dir in "$target_dir"/*/; do
  latest=$(find "$dir" -maxdepth 1 -type f -printf "%T@\n" 2>/dev/null | sort -nr | head -n 1)
  now=$(date +%s)
  if [[ -z "$latest" ]]; then
    print_color white "$(basename "$dir")/ (empty or no files)"
    continue
  fi
  delta_days=$(((now - ${latest%.*}) / 86400))

  # Determine color
  if ((delta_days < level_1_age_in_days)); then
    color=$level_1_color
  elif ((delta_days < level_2_age_in_days)); then
    color=$level_2_color
  elif ((delta_days < level_3_age_in_days)); then
    color=$level_3_color
  else
    color="blue"
  fi

  # Git diff stats (if in a git repo)
  if git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null; then
    stats=$(git -C "$dir" log --since="${delta_days} days ago" --pretty=tformat: --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {print (added ? "+"added : "+0") " / " (deleted ? "-"deleted : "-0")}')
  else
    stats="(no git)"
  fi

  print_color "$color" "$(basename "$dir")/ [$delta_days days] $stats"
done
