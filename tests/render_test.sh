#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
socket='slots-test'
failures=0
checks=0

main() {
  LC_ALL="$(a_utf8_locale)"
  export LC_ALL
  check_defaults
  check_custom_palette
  check_plain_and_boxed_slots
  check_rectangle_edges
  check_transparent_bar
  check_phase_two_options
  check_empty_slots_disappear
  tmux -L "$socket" kill-server 2>/dev/null || true
  report
}

a_utf8_locale() {
  local candidate
  for candidate in en_US.UTF-8 C.UTF-8 C.utf8; do
    if locale -a 2>/dev/null | grep -qxF "$candidate"; then
      printf '%s' "$candidate"
      return
    fi
  done
  printf '%s' "${LC_ALL:-C}"
}

theme_from_fixture() {
  tmux -L "$socket" kill-server 2>/dev/null || true
  tmux -L "$socket" -f "$repository_root/tests/fixtures/$1" new-session -d -s slots
  tmux -L "$socket" run-shell "$repository_root/slots.tmux"
}

expect_option() {
  local description="$1" option="$2" expected="$3" actual
  actual="$(tmux -L "$socket" show-option -gv "$option")"
  expect_equal "$description" "$expected" "$actual"
}

expect_expansion() {
  local description="$1" expected="$2" actual
  actual="$(tmux -L "$socket" display-message -p "$(tmux -L "$socket" show-option -gv status-right)")"
  expect_equal "$description" "$expected" "$actual"
}

expect_equal() {
  local description="$1" expected="$2" actual="$3"
  checks=$((checks + 1))
  if [ "$actual" = "$expected" ]; then
    printf '  ok   %s\n' "$description"
    return
  fi
  failures=$((failures + 1))
  printf '  FAIL %s\n    expected |%s|\n    actual   |%s|\n' "$description" "$expected" "$actual"
}

report() {
  printf '\n%d checks, %d failures\n' "$checks" "$failures"
  [ "$failures" -eq 0 ]
}

check_defaults() {
  printf 'defaults.conf\n'
  theme_from_fixture defaults.conf
  expect_option 'refresh rate' status-interval '1'
  expect_option 'left length' status-left-length '50'
  expect_option 'right length' status-right-length '200'
  expect_option 'bar style' status-style 'bg=#403D41,fg=white'
  expect_option 'pane border' pane-border-style 'fg=#6272a4'
  expect_option 'active pane border' pane-active-border-style 'fg=#ff79c6'
  expect_option 'message style' message-style 'bg=#726F72,fg=#FFFFFF'
  expect_option 'activity monitoring' monitor-activity 'on'
  expect_option 'visual bell' visual-bell 'on'
  expect_option 'bell action' bell-action 'other'
  expect_option 'inactive window style' window-status-style 'bg=#403D41,fg=#f8f8f2'
  expect_option 'activity style' window-status-activity-style 'bg=#403D41,fg=#f8f8f2'
  expect_option 'bell style' window-status-bell-style 'bg=#403D41,fg=#f8f8f2'
  expect_option 'last window style' window-status-last-style 'bg=#403D41,fg=#f8f8f2'
  expect_option 'window justify' status-justify 'left'
  expect_option 'window separator' window-status-separator ''
  expect_option 'session box' status-left \
    '#[bg=colour49,fg=colour16,bold]#{?client_prefix,#[bg=#FF915B],} #S:#I.#P #[bg=#403D41,fg=colour49]#{?client_prefix,#[fg=#FF915B],}'
  expect_option 'current window' window-status-current-format \
    '#[fg=#403D41,bg=colour211]#[bg=colour211,fg=colour16] #I #W #[fg=colour211,bg=#403D41] '
  expect_option 'other window' window-status-format \
    '#[bg=#403D41,fg=#f8f8f2] #I #W #[fg=#403D41,bg=#403D41]'
  expect_option 'built-in time slot' status-right \
    "#[bg=#403D41,fg=white] #(date +'%a %d/%m %H:%M') "
}

check_custom_palette() {
  printf 'custom_palette.conf\n'
  theme_from_fixture custom_palette.conf
  expect_option 'overridden bar colour' status-style 'bg=#1e1e2e,fg=white'
  expect_option 'overridden session colour' status-left \
    '#[bg=#a6e3a1,fg=colour16,bold]#{?client_prefix,#[bg=#FF915B],} #S:#I.#P #[bg=#1e1e2e,fg=#a6e3a1]#{?client_prefix,#[fg=#FF915B],}>'
  expect_option 'added palette name and raw colours' status-right \
    '#[fg=#94e2d5,bg=#1e1e2e]<#[bg=#94e2d5,fg=colour16] CPU#[fg=#FF0000,bg=#94e2d5]<#[bg=#FF0000,fg=colour232] RAW#[bg=#FF0000] '
}

check_plain_and_boxed_slots() {
  printf 'plain_and_boxed_slots.conf\n'
  theme_from_fixture plain_and_boxed_slots.conf
  expect_option 'chevron chaining across plain and boxed slots' status-right \
    '#[bg=#403D41,fg=white] #(cat ~/.claude/statusline-tmux.txt) #[bg=#403D41,fg=white] #{pomodoro_status} #[bg=#403D41,fg=white] #{ping}ms #[fg=#FF915B,bg=#403D41]#[bg=#FF915B,fg=colour16] CPU #{cpu_percentage}#[fg=#FFD64C,bg=#FF915B]#[bg=#FFD64C,fg=colour16] #{sysstat_mem}#[bg=#FFD64C] '
}

check_rectangle_edges() {
  printf 'rectangle_edges.conf\n'
  theme_from_fixture rectangle_edges.conf
  expect_option 'flat session box' status-left \
    '#[bg=colour49,fg=colour16,bold]#{?client_prefix,#[bg=#FF915B],} #S:#I.#P #[bg=#403D41] '
  expect_option 'flat current window' window-status-current-format \
    '#[bg=#403D41] #[bg=colour211,fg=colour16] #I #W #[bg=#403D41]  '
  expect_option 'flat other window' window-status-format \
    '#[bg=#403D41,fg=#f8f8f2] #I #W #[bg=#403D41] '
  expect_option 'flat slots' status-right \
    '#[bg=#403D41] #[bg=#FF915B,fg=colour16] CPU#[bg=#403D41] #[bg=#FFD64C,fg=colour16] RAM#[bg=#FFD64C] '
  expect_equal 'no powerline glyphs anywhere' '' "$(every_rendered_option | tr -cd '')"
}

check_transparent_bar() {
  printf 'transparent_bar.conf\n'
  theme_from_fixture transparent_bar.conf
  expect_option 'transparent bar style' status-style 'bg=default,fg=white'
  expect_option 'transparent session chevron' status-left \
    '#[bg=colour49,fg=colour16,bold]#{?client_prefix,#[bg=#FF915B],} #S:#I.#P #[bg=default,fg=colour49]#{?client_prefix,#[fg=#FF915B],}'
  expect_option 'transparent other window' window-status-format \
    '#[bg=default,fg=#f8f8f2] #I #W #[fg=default,bg=default]'
  expect_option 'transparent plain slot' status-right \
    "#[bg=default,fg=white] #(date +'%a %d/%m %H:%M') "
}

check_phase_two_options() {
  printf 'phase_two_options.conf\n'
  theme_from_fixture phase_two_options.conf
  expect_option 'window justify' status-justify 'centre'
  expect_option 'activity monitoring off' monitor-activity 'off'
  expect_option 'visual bell off' visual-bell 'off'
  expect_option 'bell action off' bell-action 'none'
  expect_option 'overridden activity style' window-status-activity-style 'bg=#403D41,fg=#f8f8f2,underscore'
  expect_option 'overridden bell style' window-status-bell-style 'bg=#403D41,fg=#f8f8f2,underscore'
  expect_option 'unbolded session box with wider padding' status-left \
    '#[bg=colour49,fg=colour16]#{?client_prefix,#[bg=#FF915B],}  #S:#I.#P  #[bg=#403D41,fg=colour49]#{?client_prefix,#[fg=#FF915B],}'
  expect_option 'window flags and no padding' window-status-format \
    '#[bg=#403D41,fg=#f8f8f2]#I #W#F#[fg=#403D41,bg=#403D41]'
  expect_option 'slots wrapped in an emptiness guard' status-right \
    '#{?#{!=:#(tmux list-sessions | wc -l | tr -d "[:space:]") sessions,},#[bg=#403D41#,fg=white]#(tmux list-sessions | wc -l | tr -d "[:space:]") sessions,}#{?#{!=:CPU,},#[fg=#FF915B#,bg=#{?#{!=:#(tmux list-sessions | wc -l | tr -d "[:space:]") sessions,},##403D41,##403D41}]#[bg=#FF915B#,fg=colour16]CPU,}#[bg=#{?#{!=:CPU,},##FF915B,#{?#{!=:#(tmux list-sessions | wc -l | tr -d "[:space:]") sessions,},##403D41,##403D41}}]'
}

check_empty_slots_disappear() {
  printf 'hidden slots at runtime\n'
  theme_from_fixture phase_two_options.conf
  tmux -L "$socket" set-option -g @slot-list 'blank cpu'
  tmux -L "$socket" set-option -g @slot-blank-colors 'yellow ink'

  tmux -L "$socket" set-option -g @slot-blank-format '#{a_plugin_that_is_not_installed}'
  tmux -L "$socket" run-shell "$repository_root/slots.tmux"
  expect_expansion 'an empty slot leaves no gap and no colour seam' \
    '#[fg=#FF915B,bg=#403D41]#[bg=#FF915B,fg=colour16]CPU#[bg=#FF915B]'

  tmux -L "$socket" set-option -g @slot-blank-format 'HERE'
  tmux -L "$socket" run-shell "$repository_root/slots.tmux"
  expect_expansion 'a filled slot chains into the next box' \
    '#[fg=#FFD64C,bg=#403D41]#[bg=#FFD64C,fg=colour16]HERE#[fg=#FF915B,bg=#FFD64C]#[bg=#FF915B,fg=colour16]CPU#[bg=#FF915B]'
}

every_rendered_option() {
  local option
  for option in status-left status-right window-status-format window-status-current-format; do
    tmux -L "$socket" show-option -gv "$option"
  done
}

main
