#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=en_US.UTF-8

scripts_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/glyphs.sh
. "$scripts_directory/glyphs.sh"
# shellcheck source=scripts/options.sh
. "$scripts_directory/options.sh"
# shellcheck source=scripts/palette.sh
. "$scripts_directory/palette.sh"
# shellcheck source=scripts/edges.sh
. "$scripts_directory/edges.sh"
# shellcheck source=scripts/session_box.sh
. "$scripts_directory/session_box.sh"
# shellcheck source=scripts/window_list.sh
. "$scripts_directory/window_list.sh"
# shellcheck source=scripts/builtin_slots.sh
. "$scripts_directory/builtin_slots.sh"
# shellcheck source=scripts/slots.sh
. "$scripts_directory/slots.sh"
# shellcheck source=scripts/chrome.sh
. "$scripts_directory/chrome.sh"

main() {
  load_palette
  apply_refresh_rate
  apply_left_length
  apply_right_length
  apply_bar_style
  apply_pane_border_style
  apply_active_pane_border_style
  apply_message_style
  apply_activity_monitoring
  apply_visual_bell
  apply_bell_action
  apply_alert_styles
  apply_window_justify
  apply_window_separator
  apply_status_left
  apply_current_window_format
  apply_other_window_format
  apply_status_right
}

apply_status_left() {
  tmux set-option -g status-left "$(session_box)"
}

apply_current_window_format() {
  tmux set-option -g window-status-current-format "$(current_window_segment)"
}

apply_other_window_format() {
  tmux set-option -g window-status-format "$(other_window_segment)"
}

apply_status_right() {
  tmux set-option -g status-right "$(slot_container)"
}

session_box() {
  local weight=''
  if option_is_true '@slot-session-bold' 'true'; then
    weight='bold'
  fi
  render_session_box \
    "$(tmux_option '@slot-session-format' '#S:#I.#P')" \
    "$(color_pair_background '@slot-session-colors' 'mint ink')" \
    "$(color_pair_foreground '@slot-session-colors' 'mint ink')" \
    "$(color_pair_background '@slot-session-prefix-colors' 'orange ink')" \
    "$(padding_of_width "$(tmux_option '@slot-session-padding' '1')")" \
    "$weight"
}

current_window_segment() {
  render_current_window \
    "$(window_text)" \
    "$(color_pair_background '@slot-window-current-colors' 'pink ink')" \
    "$(color_pair_foreground '@slot-window-current-colors' 'pink ink')" \
    "$(bar_background)" \
    "$(left_pad)" \
    "$(right_pad)"
}

other_window_segment() {
  render_other_window \
    "$(window_text)" \
    "$(color_pair_background '@slot-window-colors' 'bar snow')" \
    "$(color_pair_foreground '@slot-window-colors' 'bar snow')" \
    "$(bar_background)" \
    "$(left_pad)" \
    "$(right_pad)"
}

window_text() {
  local text
  text="$(tmux_option '@slot-window-format' '#I #W')"
  if option_is_true '@slot-window-flags' 'false'; then
    printf '%s#F' "$text"
  else
    printf '%s' "$text"
  fi
}

slot_container() {
  render_slots \
    "$(tmux_option '@slot-list' 'time')" \
    "$(bar_background)" \
    "$(bar_foreground)" \
    "$(left_pad)" \
    "$(right_pad)"
}

main
