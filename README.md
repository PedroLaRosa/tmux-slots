# tmux-slots

A tmux status theme whose right-hand side is a row of **slots** that other plugins fill.

tmux-slots draws the boxes, the chevrons and the colours. It never computes a CPU
percentage, a ping time or the weather — you point a slot at a format string, and
whichever plugin owns that format fills it in.

## Anatomy

```
 mysession:1.0  0 bash  1 vim              Mon, 08 Sep  CPU 12% MEM 41%
└──────┬───────┘└───────┬──────┘           └─────┬────┘ └──────┬──────┘
   session box      window list          plain slot        boxed slots
```

A slot is **plain** (text sitting straight on the bar) until you give it colours, at
which point it becomes a **box** with a chevron that tapers into whatever sits to its
left. The chevron colours are chained for you, left to right — there is no
`*_NEXT_BG` variable to keep in sync.

## Install

### TPM

```tmux
set -g @plugin 'PedroLaRosa/tmux-slots'
run '~/.tmux/plugins/tpm/tpm'
```

Then press `prefix + I`.

### Manual

```tmux
run-shell '~/path/to/tmux-slots/slots.tmux'
```

Requires tmux 3.1 or newer and bash. The default `arrow` edges need a Nerd Font or
a Powerline-patched font; see [Terminals without a Nerd Font](#terminals-without-a-nerd-font)
if you do not have one.

## ⚠️ Plugin order matters

**List tmux-slots above every plugin whose formats it renders.**

```tmux
set -g @plugin 'PedroLaRosa/tmux-slots'      # first
set -g @slot-list "cpu ram"
set -g @slot-cpu-format "CPU #{cpu_percentage}"
set -g @slot-cpu-colors "orange ink"
set -g @slot-ram-format "#{sysstat_mem}"
set -g @slot-ram-colors "yellow ink"

set -g @plugin 'tmux-plugins/tmux-cpu'       # after
set -g @plugin 'samoshkin/tmux-plugin-sysstat'
run '~/.tmux/plugins/tpm/tpm'
```

Plugins such as tmux-cpu work by rewriting their own placeholder inside `status-right`
when TPM runs them. tmux-slots must therefore have written `status-right` **before**
they run. Get the order wrong and nothing breaks loudly — the slot simply renders
empty, which is a slow thing to debug.

## Zero configuration

Install it, press `prefix + I`, and you get the full bar with a built-in `time` slot
on the right. tmux-slots ships no dependency on any other plugin, so the default right
side uses only what tmux itself can produce.

## Slots

```tmux
set -g @slot-list "pomodoro ping cpu ram"

set -g @slot-pomodoro-format "#{pomodoro_status}"   # no colours -> plain text
set -g @slot-ping-format "#{ping}ms"                # no colours -> plain text
set -g @slot-cpu-format "CPU #{cpu_percentage}"
set -g @slot-cpu-colors "orange ink"                # colours -> boxed
set -g @slot-ram-format "#{sysstat_mem}"
set -g @slot-ram-colors "yellow ink"
```

`@slot-list` is a space-separated list rendered left to right. Slot names are yours to
choose — `cpu`, `ram`, `claude` and `weather` are only examples. Each slot reads two
options:

| Option | Meaning |
|---|---|
| `@slot-<name>-format` | the tmux format string to render. Required, except for the built-in `time` and `session-count` slots |
| `@slot-<name>-colors` | `"bg fg"`. Present means a boxed slot, absent means plain text on the bar |

Colours are palette names (`orange`, `ink`, …) or raw tmux colours
(`#FF915B`, `colour16`, `default`). See [docs/COLORS.md](docs/COLORS.md).

## Recipes

### The Claude Code status line as a slot

```tmux
set -g @slot-list "claude cpu"
set -g @slot-claude-format "#(cat ~/.claude/statusline-tmux.txt)"
```

### Terminals without a Nerd Font

```tmux
set -g @slot-edges "rectangle"
```

Boxes become flat blocks separated by a single bar-coloured column, and no Powerline
glyph is emitted anywhere. Everything else — colours, prefix highlight, slot
chaining — behaves identically.

### Migrating from a hand-built status line

The bar this theme was extracted from looked like this:

```tmux
set -g status-style "bg=#403D41 fg=white"
set -g status-left "#[bg=colour49,fg=colour16,bold]#{?client_prefix,#[bg=#FF915B],} #S:#I.#P #[bg=default,fg=colour49]#{?client_prefix,#[fg=#FF915B],}"
set -g window-status-current-format "#[fg=#403D41,bg=colour211]#[fg=colour16,bg=colour211] #I #W #[fg=colour211,bg=#403D41] "
CPU_BG="#FF915B"; RAM_BG="#FFD64C"; CPU_NEXT_BG="$RAM_BG"
set -g status-right "... #[fg=$CPU_BG,bg=$BAR_BG]#[bg=$CPU_BG,fg=colour16] CPU #{cpu_percentage}#[fg=$RAM_BG,bg=$CPU_BG]..."
```

The whole thing becomes:

```tmux
set -g @plugin 'PedroLaRosa/tmux-slots'
set -g @slot-list "cpu ram"
set -g @slot-cpu-format "CPU #{cpu_percentage}"
set -g @slot-cpu-colors "orange ink"
set -g @slot-ram-format "#{sysstat_mem}"
set -g @slot-ram-colors "yellow ink"
```

Every default in tmux-slots is the value that bar used, so anything you do not
override renders as it did before.

## Documentation

- [docs/CONFIG.md](docs/CONFIG.md) — every option, with defaults.
- [docs/COLORS.md](docs/COLORS.md) — the palette, how to override it, and
  ready-made Catppuccin and Gruvbox recipes.

## What this theme does not touch

Key bindings and non-visual options (`mouse`, `base-index`, `prefix`, …) are yours.
tmux-slots writes only the status line, the pane borders, the message style and the
activity alerts.

## Development

```sh
shellcheck -x slots.tmux scripts/apply_theme.sh tests/render_test.sh
tests/render_test.sh
```

`tests/render_test.sh` boots a throwaway tmux server on the `slots-test` socket for
each fixture in `tests/fixtures/`, applies the theme and asserts the exact strings
tmux ends up holding.

## License

[MIT](LICENSE)
