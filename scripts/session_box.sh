#!/usr/bin/env bash

render_session_box() {
  local text="$1" background="$2" foreground="$3" prefix_background="$4"
  local padding="$5" weight="$6"
  printf '%s%s%s%s%s%s' \
    "$(style "$(box_attributes "$background" "$foreground" "$weight")")" \
    "$(when_prefix "$(style "bg=$prefix_background")")" \
    "$padding" "$text" "$padding" \
    "$(session_box_edge "$background" "$prefix_background")"
}

box_attributes() {
  local background="$1" foreground="$2" weight="$3"
  if [ -z "$weight" ]; then
    printf 'bg=%s,fg=%s' "$background" "$foreground"
  else
    printf 'bg=%s,fg=%s,%s' "$background" "$foreground" "$weight"
  fi
}

session_box_edge() {
  local background="$1" prefix_background="$2"
  if edges_are_rectangles; then
    left_edge "$background" "$(bar_background)"
    return
  fi
  printf '%s%s%s' \
    "$(style "bg=$(bar_background),fg=$background")" \
    "$(when_prefix "$(style "fg=$prefix_background")")" \
    "$(left_edge_glyph)"
}
