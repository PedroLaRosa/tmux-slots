#!/usr/bin/env bash

render_slots() {
  local slot_names="$1" bar="$2" bar_text="$3"
  local left_padding="$4" right_padding="$5"
  local name format background chunk
  local last_slot_was_boxed='false' any_slot_was_boxed='false'
  local previous_background
  previous_background="$(chain_start "$bar")"
  for name in $slot_names; do
    format="$(slot_format "$name")"
    if [ -z "$format" ]; then
      continue
    fi
    if is_boxed_slot "$name"; then
      background="$(slot_background "$name")"
      chunk="$(render_boxed_slot \
        "$format" \
        "$background" \
        "$(slot_foreground "$name")" \
        "$previous_background" \
        "$left_padding")"
      last_slot_was_boxed='true'
      any_slot_was_boxed='true'
    else
      background="$bar"
      chunk="$(render_plain_slot \
        "$format" "$bar" "$bar_text" \
        "$left_padding" "$right_padding")"
      last_slot_was_boxed='false'
    fi
    previous_background="$(background_after_slot "$format" "$background" "$previous_background")"
    printf '%s' "$(hidden_when_empty "$format" "$chunk")"
  done
  if chain_needs_closing "$last_slot_was_boxed" "$any_slot_was_boxed"; then
    printf '%s%s' "$(style "bg=$previous_background")" "$right_padding"
  fi
}

chain_start() {
  if hides_empty_slots; then
    escaped_hashes "$1"
  else
    printf '%s' "$1"
  fi
}

background_after_slot() {
  local format="$1" background="$2" previous_background="$3"
  if hides_empty_slots; then
    printf '#{?#{!=:%s,},%s,%s}' \
      "$(escaped_for_conditional "$format")" \
      "$(escaped_hashes "$background")" \
      "$previous_background"
    return
  fi
  printf '%s' "$background"
}

escaped_hashes() {
  printf '%s' "${1//#/##}"
}

chain_needs_closing() {
  local last_slot_was_boxed="$1" any_slot_was_boxed="$2"
  if [ "$last_slot_was_boxed" = 'true' ]; then
    return 0
  fi
  if [ "$any_slot_was_boxed" = 'true' ] && hides_empty_slots; then
    return 0
  fi
  return 1
}

render_boxed_slot() {
  local format="$1" background="$2" foreground="$3"
  local previous_background="$4" left_padding="$5"
  printf '%s%s%s%s' \
    "$(right_edge "$previous_background" "$background")" \
    "$(style "bg=$background,fg=$foreground")" \
    "$left_padding" "$format"
}

render_plain_slot() {
  local format="$1" background="$2" foreground="$3"
  local left_padding="$4" right_padding="$5"
  printf '%s%s%s%s' \
    "$(style "bg=$background,fg=$foreground")" \
    "$left_padding" "$format" "$right_padding"
}

hidden_when_empty() {
  local format="$1" chunk="$2"
  if hides_empty_slots; then
    printf '#{?#{!=:%s,},%s,}' \
      "$(escaped_for_conditional "$format")" \
      "$(escaped_for_conditional "$chunk")"
  else
    printf '%s' "$chunk"
  fi
}

hides_empty_slots() {
  option_is_true '@slot-hide-empty-slots' 'false'
}

escaped_for_conditional() {
  local text="$1" escaped='' character depth=0 index=0
  while [ "$index" -lt "${#text}" ]; do
    character="${text:index:1}"
    case "$character" in
      '{') depth=$((depth + 1)) ;;
      '}') if [ "$depth" -gt 0 ]; then depth=$((depth - 1)); fi ;;
      ',') if [ "$depth" -eq 0 ]; then character='#,'; fi ;;
    esac
    escaped="$escaped$character"
    index=$((index + 1))
  done
  printf '%s' "$escaped"
}

is_boxed_slot() {
  option_is_set "@slot-$1-colors"
}

slot_format() {
  tmux_option "@slot-$1-format" "$(builtin_slot_format "$1")"
}

slot_background() {
  color_pair_background "@slot-$1-colors" ''
}

slot_foreground() {
  color_pair_foreground "@slot-$1-colors" ''
}
