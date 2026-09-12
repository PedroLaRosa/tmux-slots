#!/usr/bin/env bash

apply_refresh_rate() {
  tmux set-option -g status-interval "$(tmux_option '@slot-refresh-rate' '1')"
}

apply_left_length() {
  tmux set-option -g status-left-length "$(tmux_option '@slot-left-length' '50')"
}

apply_right_length() {
  tmux set-option -g status-right-length "$(tmux_option '@slot-right-length' '200')"
}

apply_bar_style() {
  tmux set-option -g status-style "bg=$(bar_background),fg=$(bar_foreground)"
}

apply_pane_border_style() {
  tmux set-option -g pane-border-style \
    "fg=$(color_pair_background '@slot-border-colors' 'slate magenta')"
}

apply_active_pane_border_style() {
  tmux set-option -g pane-active-border-style \
    "fg=$(color_pair_foreground '@slot-border-colors' 'slate magenta')"
}

apply_message_style() {
  tmux set-option -g message-style \
    "bg=$(color_pair_background '@slot-message-colors' 'smoke chalk'),fg=$(color_pair_foreground '@slot-message-colors' 'smoke chalk')"
}

apply_activity_monitoring() {
  tmux set-option -g monitor-activity "$(switch_for '@slot-monitor-activity' 'true')"
}

apply_visual_bell() {
  tmux set-option -g visual-bell "$(switch_for '@slot-monitor-activity' 'true')"
}

apply_bell_action() {
  tmux set-option -g bell-action "$(bell_action)"
}

# ponytail: attributes only. A colour here is swallowed by window-status-format,
# which sets bg and fg itself; only attributes survive. tmux's default is
# 'reverse', which the format cannot clear -- that is the white tab on activity.
apply_alert_styles() {
  local alert
  alert="$(tmux_option '@slot-window-alert-style' 'bold')"
  tmux set-option -g window-status-activity-style "$alert"
  tmux set-option -g window-status-bell-style "$alert"
}

bell_action() {
  if option_is_true '@slot-monitor-activity' 'true'; then
    printf 'other'
  else
    printf 'none'
  fi
}

apply_window_justify() {
  tmux set-option -g status-justify "$(tmux_option '@slot-window-justify' 'left')"
}

apply_window_separator() {
  tmux set-option -g window-status-separator ''
}

switch_for() {
  if option_is_true "$1" "$2"; then
    printf 'on'
  else
    printf 'off'
  fi
}
