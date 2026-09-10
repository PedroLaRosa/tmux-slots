#!/usr/bin/env bash

render_current_window() {
  local text="$1" background="$2" foreground="$3" bar="$4"
  local left_padding="$5" right_padding="$6"
  printf '%s%s%s%s%s%s ' \
    "$(left_edge "$bar" "$background")" \
    "$(style "bg=$background,fg=$foreground")" \
    "$left_padding" "$text" "$right_padding" \
    "$(left_edge "$background" "$bar")"
}

render_other_window() {
  local text="$1" background="$2" foreground="$3" bar="$4"
  local left_padding="$5" right_padding="$6"
  printf '%s%s%s%s%s' \
    "$(style "bg=$background,fg=$foreground")" \
    "$left_padding" "$text" "$right_padding" \
    "$(left_edge "$background" "$bar")"
}
