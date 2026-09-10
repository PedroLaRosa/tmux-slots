#!/usr/bin/env bash

load_palette() {
  apply_default_palette
  apply_user_palette
  apply_bar_transparency
}

apply_bar_transparency() {
  if option_is_true '@slot-transparent-bar' 'false'; then
    set_color "$(first_word "$(tmux_option '@slot-bar-colors' 'bar bar_text')")" 'default'
  fi
}

apply_default_palette() {
  set_color bar '#403D41'
  set_color bar_text 'white'
  set_color snow '#f8f8f2'
  set_color ink 'colour16'
  set_color mint 'colour49'
  set_color pink 'colour211'
  set_color orange '#FF915B'
  set_color yellow '#FFD64C'
  set_color sand 'colour137'
  set_color indigo 'colour62'
  set_color paper 'colour255'
  set_color slate '#6272a4'
  set_color magenta '#ff79c6'
  set_color smoke '#726F72'
  set_color chalk '#FFFFFF'
  set_color dim 'colour240'
}

apply_user_palette() {
  local definitions line name value
  definitions="$(tmux_option '@slot-colors' '')"
  while IFS= read -r line; do
    line="$(trimmed "$line")"
    case "$line" in
      '#'*) continue ;;
      *=*) ;;
      *) continue ;;
    esac
    name="$(trimmed "${line%%=*}")"
    value="$(unquoted "$(trimmed "${line#*=}")")"
    if [ -n "$name" ]; then
      set_color "$name" "$value"
    fi
  done <<PALETTE
$definitions
PALETTE
}

set_color() {
  local key value
  key="$(palette_key "$1")"
  value="$2"
  eval "slot_color_$key=\$value"
}

palette_value() {
  local key
  key="$(palette_key "$1")"
  eval "printf '%s' \"\${slot_color_$key-}\""
}

palette_key() {
  local name="$1"
  printf '%s' "${name//[^A-Za-z0-9_]/_}"
}

resolve_color() {
  local named
  named="$(palette_value "$1")"
  if [ -n "$named" ]; then
    printf '%s' "$named"
  else
    printf '%s' "$1"
  fi
}

color_pair_background() {
  resolve_color "$(first_word "$(tmux_option "$1" "$2")")"
}

color_pair_foreground() {
  resolve_color "$(last_word "$(tmux_option "$1" "$2")")"
}
