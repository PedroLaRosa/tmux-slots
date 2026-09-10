#!/usr/bin/env bash

builtin_slot_format() {
  case "$1" in
    time) time_slot_format ;;
    session-count) session_count_slot_format ;;
    *) printf '' ;;
  esac
}

time_slot_format() {
  printf '%s' "#(date +'%a %d/%m %H:%M')"
}

session_count_slot_format() {
  printf '%s' '#(tmux list-sessions | wc -l | tr -d "[:space:]") sessions'
}
