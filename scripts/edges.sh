#!/usr/bin/env bash

style() {
  printf '#[%s]' "$1"
}

when_prefix() {
  printf '#{?client_prefix,%s,}' "$1"
}

bar_background() {
  color_pair_background '@slot-bar-colors' 'bar bar_text'
}

bar_foreground() {
  color_pair_foreground '@slot-bar-colors' 'bar bar_text'
}

edges_are_rectangles() {
  case "$(tmux_option '@slot-edges' 'arrow')" in
    rectangle | rectangles | false | off | no | 0) return 0 ;;
    *) return 1 ;;
  esac
}

left_edge_glyph() {
  tmux_option '@slot-left-edge' "$LEFT_CHEVRON"
}

right_edge_glyph() {
  tmux_option '@slot-right-edge' "$RIGHT_CHEVRON"
}

left_edge() {
  local from_background="$1" to_background="$2"
  edge_between "$(left_edge_glyph)" "$from_background" "$to_background"
}

right_edge() {
  local from_background="$1" to_background="$2"
  edge_between "$(right_edge_glyph)" "$to_background" "$from_background"
}

edge_between() {
  local glyph="$1" glyph_foreground="$2" glyph_background="$3"
  if edges_are_rectangles; then
    printf '%s ' "$(style "bg=$(bar_background)")"
    return
  fi
  printf '%s%s' "$(style "fg=$glyph_foreground,bg=$glyph_background")" "$glyph"
}
