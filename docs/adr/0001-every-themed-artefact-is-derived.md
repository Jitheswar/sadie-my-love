# Every themed artefact is derived, never pinned

The theme's whole premise is that the palette rotates with the wallpaper, so any artefact carrying literal colours silently opts out of the theme and drifts.
We therefore require every themed artefact to be computed from `colors.toml` at apply time, and we accept writing and maintaining our own generator whenever Omarchy's stock template cannot produce the design we want.

## Why this is not obvious

`bin/generate-btop` reimplements something Omarchy already has a template for, which looks like duplication worth deleting.
It is not.
The stock `btop.theme.tpl` sets `theme[main_bg]` to the palette background, which makes btop an opaque slab inside a terminal this theme deliberately runs at `0.96` opacity, and it paints box titles in plain foreground where this theme wants amber.
Deleting our generator in favour of the template would lose both.

The generator exists so that the hand-tuned btop design can be kept *and* rotate.
It expresses the design once against the reference palette and re-applies the live rotation to it, exactly as `bin/generate-palettes` does for `colors.toml`.
Because rotation preserves lightness and chroma, the tuning survives by construction.

## Considered options

**Ship a hand-written `btop.theme`.**
What the theme did originally.
Rejected: it held the reference copper while the bar, borders, and terminal rotated up to 19 degrees away from it on wallpaper 02, which is plainly visible side by side.

**Delete `btop.theme` and take Omarchy's template.**
Rejected for the design reasons above.

**Keep a pinned editor colourscheme.**
The theme originally pinned Kanagawa Dragon via `neovim.lua` and `vscode.json`, which had no relationship to the palette at all.
Rejected: deleting both lets Omarchy generate `aether.nvim` and a VS Code theme straight from `colors.toml`, which is palette-exact and rotates for free.

## Consequences

`bin/apply-palette` is the only place that swaps the live palette, so any future generator must be invoked from there, between the `colors.toml` copy and `omarchy-theme-set`.

Adding a themed artefact with literal colours in it is a regression against this ADR even when it looks correct at the time, because it will only look correct on one wallpaper.
