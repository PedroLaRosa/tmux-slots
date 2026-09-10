# Colours

Anywhere tmux-slots expects a colour you may write either a **palette name** or a
**raw tmux colour**. These two lines mean exactly the same thing:

```tmux
set -g @slot-cpu-colors "orange ink"
set -g @slot-cpu-colors "#FF915B colour16"
```

Raw colours are whatever tmux accepts: `#rrggbb`, `colour0`–`colour255`, the eight
named ANSI colours, and `default` for "whatever the terminal uses".

## The default palette

| Name | Value | Used by default for |
|---|---|---|
| `bar` | `#403D41` | status bar background, chevron gaps |
| `bar_text` | `white` | status bar foreground |
| `snow` | `#f8f8f2` | inactive window text |
| `ink` | `colour16` | text inside coloured boxes |
| `mint` | `colour49` | session box |
| `pink` | `colour211` | current window box |
| `orange` | `#FF915B` | session box while the prefix key is held |
| `yellow` | `#FFD64C` | — |
| `sand` | `colour137` | — |
| `indigo` | `colour62` | — |
| `paper` | `colour255` | — |
| `slate` | `#6272a4` | inactive pane border |
| `magenta` | `#ff79c6` | active pane border |
| `smoke` | `#726F72` | message line background |
| `chalk` | `#FFFFFF` | message line foreground |
| `dim` | `colour240` | — |

The names with no default use are there for your slots: `yellow`, `sand`, `indigo`,
`paper` and `dim` are the colours the reference bar used for RAM, weather, the clock
and dividers.

## Overriding the palette

`@slot-colors` is a block of `name='value'` lines. It both **overrides** existing
names and **adds** new ones:

```tmux
set -g @slot-colors "
bar='#1e1e2e'
mint='#a6e3a1'
teal='#94e2d5'
"
set -g @slot-cpu-colors "teal ink"
```

Redefining `bar` recolours the status line, the chevron gaps and the inactive window
background in one go, because everything that needs "the bar's colour" asks the
palette for it.

Quotes are optional and comment lines starting with `#` are ignored.

## Catppuccin Mocha

```tmux
set -g @slot-colors "
bar='#1e1e2e'
bar_text='#cdd6f4'
snow='#a6adc8'
ink='#1e1e2e'
mint='#a6e3a1'
pink='#f5c2e7'
orange='#fab387'
yellow='#f9e2af'
sand='#eba0ac'
indigo='#89b4fa'
paper='#1e1e2e'
slate='#45475a'
magenta='#cba6f7'
smoke='#313244'
chalk='#cdd6f4'
dim='#6c7086'
"
```

## Gruvbox Dark

```tmux
set -g @slot-colors "
bar='#3c3836'
bar_text='#ebdbb2'
snow='#bdae93'
ink='#282828'
mint='#b8bb26'
pink='#d3869b'
orange='#fe8019'
yellow='#fabd2f'
sand='#d65d0e'
indigo='#83a598'
paper='#282828'
slate='#665c54'
magenta='#fb4934'
smoke='#504945'
chalk='#fbf1c7'
dim='#928374'
"
```

## Transparent bar

```tmux
set -g @slot-transparent-bar "true"
set -g @slot-edges "rectangle"
```

This resolves the bar's colour to `default`, so the terminal shows through the bar,
the chevron gaps and the inactive windows. See the note in
[CONFIG.md](CONFIG.md#bar) for why `rectangle` edges pair best with it.
