# kall

**Your launcher sucks. Fix it.**

<p align="center">
  <img src="https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white" alt="Bash" />
  <img src="https://img.shields.io/github/license/shaiknoorullah/kall?style=flat-square&color=blue" alt="MIT License" />
  <img src="https://img.shields.io/badge/platform-X11%20%7C%20Wayland%20%7C%20macOS-informational?style=flat-square" alt="Platforms" />
  <img src="https://img.shields.io/github/stars/shaiknoorullah/kall?style=flat-square&color=yellow" alt="Stars" />
</p>

<p align="center"><em>Under active development — v2.0 coming soon</em></p>

---

## What is kall

Every Linux rice eventually grows a pile of disconnected scripts — one for the power menu, another for screenshots, a third for clipboard history, all hardwired to one menu backend. Swap rofi for wofi and half of them break.

kall is a modular, backend-agnostic command center. Pure bash, zero Python. 26 modules, 6 menu backends, 6 color palettes. Install only what you need, swap the backend without touching your config.

## Quick install

```bash
curl -fsSL kall.sh/install | bash
kall setup
```

## What's in the box

| Category | Modules |
|---|---|
| **System** | `power-menu` `display` `bluetooth` `notifications` `systemd` `wallpaper` `weather` |
| **Productivity** | `clipboard` `screenshot` `calculator` `emoji` `glyph` `media` `launcher` |
| **Developer** | `git-profiles` `tmux` `projects` `keybindings` |
| **Browser** | `bookmarks` `websearch` `zen-tabs` `zen-workspaces` |
| **Notes** | `obsidian` `obsidian-search` |
| **Appearance** | `theme-selector` `style-selector` |

All 26 modules ship as self-contained directories with a `module.yml` contract. Enable them individually or in groups.

## Backends

| Backend | Environment |
|---|---|
| **rofi** | X11 / Wayland (XWayland). The heavyweight. |
| **wofi** | Native Wayland. GTK-based, no X dependency. |
| **tofi** | Minimal Wayland launcher. Fast, opinionated. |
| **fuzzel** | Wayland-native with fuzzy matching. |
| **dmenu** | The OG. X11. Pipes and nothing else. |
| **fzf** | Terminal mode. Works over SSH, in tmux, everywhere. |

Set your backend once in `kall.yml` — every module respects it.

## Themes

Six built-in palettes, hot-swappable across your entire stack:

- **Catppuccin Mocha** — warm pastels on a dark base
- **Dracula** — the purple classic
- **Nord** — arctic, low-contrast calm
- **Gruvbox** — retro, earthy warmth
- **Tokyo Night** — neon city after dark
- **Rose Pine** — muted, natural elegance

**wallbash** — opt-in dynamic theming via ImageMagick. Extract a palette from your wallpaper and propagate it everywhere. Your desktop matches your wallpaper without manual hex picking.

12 launcher styles are ported and ready to go.

## Configuration

```yaml
# ~/.config/kall/kall.yml
backend: rofi
theme: catppuccin-mocha

modules:
  - power-menu
  - clipboard
  - screenshot
  - wallpaper
  - tmux
  - projects
  - bookmarks

plugins:
  - waybar
  - dunst
  - tmux
```

## CLI

```bash
kall <module>             # Run a module
kall list                 # List enabled modules
kall list --available     # List all available modules
kall add <module>         # Enable a module
kall remove <module>      # Disable a module
kall theme set <palette>  # Switch color palette
kall doctor               # Check system health
kall setup                # Initial setup wizard
```

## Writing your own modules

A module is a directory with a `module.yml` contract and a bash script. Define your metadata, declare your dependencies, and kall handles the rest — menu rendering, theming, keybinding injection, all of it. Read the full guide at [kall.sh/docs](https://kall.sh/docs).

## Plugins

Plugins push kall's state (theme, palette, active modules) into external tools:

| Plugin | What it does |
|---|---|
| **zsh** | Syncs palette to your prompt/LS_COLORS |
| **tmux** | Applies palette to tmux status bar and panes |
| **waybar** | Injects palette colors into waybar styles |
| **polybar** | Injects palette colors into polybar config |
| **dunst / swaync** | Themes notification daemons to match your palette |
| **wallpaper hook** | Triggers wallbash re-extraction on wallpaper change |

## Keybinding injection

kall can write keybindings directly into your WM config. Supported:

`hyprland` `i3` `sway` `bspwm` `awesome` `skhd` (macOS)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Acknowledgements

Standing on the shoulders of:

[HyDE](https://github.com/HyDE-Project/HyDE) (inspiration and borrowed wisdom) — [Catppuccin](https://catppuccin.com) — [Dracula](https://draculatheme.com) — [Nord](https://nordtheme.com) — [Gruvbox](https://github.com/morhetz/gruvbox) — [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) — [Rose Pine](https://rosepinetheme.com) — [fzf](https://github.com/junegunn/fzf) — [rofi](https://github.com/davatorium/rofi) — [bat](https://github.com/sharkdp/bat) — [eza](https://github.com/eza-community/eza) — [chafa](https://github.com/hpjansson/chafa) — [fumadocs](https://fumadocs.vercel.app) — [lefthook](https://github.com/evilmartians/lefthook) — [bats-core](https://github.com/bats-core/bats-core) — [Kubernetes](https://kubernetes.io) (label system design)

## License

[MIT](LICENSE)
