# Configuration

Every option is a tmux user option, so it goes in `.tmux.conf` above
`run '~/.tmux/plugins/tpm/tpm'`:

```tmux
set -g @slot-refresh-rate 5
```

Colours are written as `"bg fg"` and may be palette names or raw tmux colours.
See [COLORS.md](COLORS.md).

## Bar

| Option | Default | Description |
|---|---|---|
| `@slot-refresh-rate` | `1` | seconds between status line redraws (`status-interval`) |
| `@slot-bar-colors` | `"bar bar_text"` | the status line's own background and foreground |
| `@slot-transparent-bar` | `false` | `true` paints the bar with the terminal's background instead of a colour |
| `@slot-left-length` | `50` | `status-left-length` |
| `@slot-right-length` | `200` | `status-right-length` |
| `@slot-border-colors` | `"slate magenta"` | inactive and active pane border colours |
| `@slot-message-colors` | `"smoke chalk"` | the message line's background and foreground |
| `@slot-monitor-activity` | `true` | `false` turns off `monitor-activity`, `visual-bell` and the bell action |

`@slot-transparent-bar` works by resolving the bar's colour to tmux's `default`, so
every place that names the bar colour — the chevron gaps, the inactive window
background — becomes transparent together.

> With `arrow` edges the current window's entering chevron has to draw the bar colour
> as a *foreground*, which transparency cannot express; it falls back to the terminal's
> default foreground. Pair `@slot-transparent-bar` with `@slot-edges rectangle` for a
> flawless transparent bar.

## Edges

Every box — the session box, the current window, a boxed slot — is separated from its
neighbour by an edge.

| Option | Default | Description |
|---|---|---|
| `@slot-edges` | `arrow` | `arrow` or `rectangle`. `true`/`false` are accepted as aliases so a Dracula config ports by renaming the option |
| `@slot-left-edge` | `` (U+E0B0) | glyph closing a box on the left-hand side of the bar |
| `@slot-right-edge` | `` (U+E0B2) | glyph opening a box on the right-hand side of the bar |
| `@slot-left-pad` | `" "` | padding before a slot's text. `false` for none |
| `@slot-right-pad` | `" "` | padding after a plain slot, and after the last box in the chain. `false` for none |

- **`arrow`** — an edge is a glyph whose foreground is the box's colour and whose
  background is its neighbour's, so the box appears to taper into what sits beside it.
  Needs a Nerd Font or a Powerline-patched font.
- **`rectangle`** — an edge is a single space carrying the bar's background, so boxes
  are flat blocks separated by one bar-coloured column. No glyphs are emitted at all,
  so any font will do.

## Session box

| Option | Default | Description |
|---|---|---|
| `@slot-session-format` | `"#S:#I.#P"` | text inside the box |
| `@slot-session-colors` | `"mint ink"` | box background and text |
| `@slot-session-prefix-colors` | `"orange ink"` | box background while the prefix key is held |
| `@slot-session-bold` | `true` | bold the box's text |
| `@slot-session-padding` | `1` | spaces on each side of the text |

Only the background of `@slot-session-prefix-colors` is used: the prefix highlight
recolours the box and its chevron, and leaves the text colour alone.

## Window list

| Option | Default | Description |
|---|---|---|
| `@slot-window-format` | `"#I #W"` | text for every window |
| `@slot-window-current-colors` | `"pink ink"` | the current window's box |
| `@slot-window-colors` | `"bar snow"` | every other window |
| `@slot-window-flags` | `false` | `true` appends `#F`, tmux's window flags (`*`, `-`, `Z`, …) |
| `@slot-window-justify` | `left` | `status-justify`: `left`, `centre` or `right` |
| `@slot-window-alert-style` | `bold` | how a window marks activity or a bell. Attributes only — `bold`, `underscore`, `default` for no marking |

`@slot-window-alert-style` takes attributes rather than colours. The theme applies
`@slot-window-colors` to every non-current window state (normal, activity, bell and
last), preventing tmux's reverse-video defaults from turning any inactive tab white.
Silence has no style of its own: tmux renders it with the activity style.

## Slots

| Option | Default | Description |
|---|---|---|
| `@slot-list` | `"time"` | space-separated slot names, rendered left to right |
| `@slot-<name>-format` | — | the tmux format string to render |
| `@slot-<name>-colors` | — | `"bg fg"`. Present means boxed, absent means plain |
| `@slot-hide-empty-slots` | `false` | `true` removes a slot from the bar whenever its format expands to nothing |

A slot with no format and no built-in default is skipped entirely, so a half-written
slot never leaves an empty box behind.

### Built-in slots

| Name | Format |
|---|---|
| `time` | `#(date +'%a %d/%m %H:%M')` |
| `session-count` | `#(tmux list-sessions \| wc -l \| tr -d "[:space:]") sessions` |

Both are ordinary defaults — set `@slot-time-format` and you override one.

### Hiding empty slots

```tmux
set -g @slot-hide-empty-slots "true"
set -g @slot-list "pomodoro cpu"
set -g @slot-pomodoro-format "#{pomodoro_status}"
set -g @slot-cpu-format "CPU #{cpu_percentage}"
set -g @slot-cpu-colors "orange ink"
```

When `#{pomodoro_status}` is empty the whole slot disappears and the chevron chaining
re-resolves around it, so a hidden box leaves neither a gap nor a stripe of its colour
behind. Commas in a slot format — including commas inside `#(...)` — are escaped for
you.

One caveat worth knowing: a slot whose format is a shell command (`#(...)`) is empty
on the very first draw, because tmux runs the command in the background and only has
its output a moment later. Such a slot appears one `@slot-refresh-rate` tick after the
bar does.

## Everything at once

```tmux
set -g @plugin 'PedroLaRosa/tmux-slots'

set -g @slot-refresh-rate 5
set -g @slot-edges "arrow"

set -g @slot-session-format "#S"
set -g @slot-session-colors "mint ink"

set -g @slot-window-format "#I #W"
set -g @slot-window-flags "true"

set -g @slot-list "pomodoro ping cpu ram clock"
set -g @slot-pomodoro-format "#{pomodoro_status}"
set -g @slot-ping-format "#{ping}ms"
set -g @slot-cpu-format "CPU #{cpu_percentage}"
set -g @slot-cpu-colors "orange ink"
set -g @slot-ram-format "#{sysstat_mem}"
set -g @slot-ram-colors "yellow ink"
set -g @slot-clock-format "%H:%M"
set -g @slot-clock-colors "indigo paper"

set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'samoshkin/tmux-plugin-sysstat'
run '~/.tmux/plugins/tpm/tpm'
```
