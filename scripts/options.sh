#!/usr/bin/env bash

tmux_option() {
  local name="$1" fallback="$2" value
  value="$(tmux show-option -gqv "$name" 2>/dev/null || true)"
  if [ -z "$value" ]; then
    printf '%s' "$fallback"
  else
    printf '%s' "$value"
  fi
}

option_is_set() {
  local value
  value="$(tmux show-option -gqv "$1" 2>/dev/null || true)"
  [ -n "$value" ]
}

option_is_true() {
  case "$(tmux_option "$1" "$2")" in
    on | yes | true | 1) return 0 ;;
    *) return 1 ;;
  esac
}

left_pad() {
  padding_option '@slot-left-pad'
}

right_pad() {
  padding_option '@slot-right-pad'
}

padding_option() {
  local value
  value="$(tmux_option "$1" ' ')"
  case "$value" in
    false | off | no | none | 0) printf '' ;;
    *) printf '%s' "$value" ;;
  esac
}

padding_of_width() {
  local width="$1" spaces=''
  case "$width" in
    '' | *[!0-9]*) width=0 ;;
  esac
  while [ "$width" -gt 0 ]; do
    spaces="$spaces "
    width=$((width - 1))
  done
  printf '%s' "$spaces"
}

first_word() {
  printf '%s' "${1%% *}"
}

last_word() {
  printf '%s' "${1##* }"
}

trimmed() {
  local text="$1"
  text="${text#"${text%%[![:space:]]*}"}"
  text="${text%"${text##*[![:space:]]}"}"
  printf '%s' "$text"
}

unquoted() {
  local text="$1"
  case "$text" in
    \'*\') text="${text#\'}" && text="${text%\'}" ;;
    \"*\") text="${text#\"}" && text="${text%\"}" ;;
  esac
  printf '%s' "$text"
}
