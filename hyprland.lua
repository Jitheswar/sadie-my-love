-- Sadie My Love - theme-scoped Hyprland look.
-- Everything here applies only while this theme is active; switching themes
-- drops all of it and restores whatever the next theme asks for.

-- Copper climbing into amber, lit like the wallpapers.
local active_border_color = { colors = { "rgba(c9714fee)", "rgba(f2bb63ee)" }, angle = 45 }

-- Inactive windows recede into the oxblood surface rather than vanishing.
local inactive_border_color = "rgba(2b2224cc)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,

      -- Hyprland's defaults here are pale and pure yellow. Rare to see, but
      -- there is no reason for the one unthemed border in the session to be
      -- the loudest colour on the screen.
      nogroup_border = inactive_border_color,
      nogroup_border_active = "rgba(f2bb63ee)",
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },

    -- Omarchy leaves the groupbar at pure white on neutral black. Inside a
    -- window wearing this theme's copper border that is the one place the
    -- palette breaks, so the tab strip is dressed here too.
    groupbar = {
      -- Square tabs inside an 8px-rounded window read as a mistake.
      gradient_rounding = 6,
      gradient_round_only_edges = true,
      -- The active tab is lit by the same copper the border starts from,
      -- kept low enough that the window content behind it still reads.
      col = {
        active = "rgba(c9714f4d)",
        inactive = "rgba(2b222466)",
      },
      text_color = "rgb(faf5f1)",
      text_color_inactive = "rgb(8f7f79)",
      -- A 1px indicator disappears against a gradient; 2px is the least
      -- that still reads as a deliberate underline.
      indicator_height = 2,
    },
  },

  -- The compositor's clear colour, seen behind windows during workspace
  -- switches and in the moment before the wallpaper paints. Hyprland defaults
  -- it to a neutral #111111, which flashes grey in a theme with no grey in it.
  misc = {
    background_color = "rgb(0b0708)",
  },

  decoration = {
    rounding = 8,
    rounding_power = 3,

    -- The unfocused window drops back a step rather than competing.
    inactive_opacity = 0.94,
    dim_inactive = true,
    dim_strength = 0.10,

    -- Shadow is tinted with the darkest background rather than pure black,
    -- so it reads as depth in this palette instead of a grey halo.
    shadow = {
      enabled = true,
      range = 26,
      render_power = 3,
      color = "rgba(0b0708bb)",
      color_inactive = "rgba(0b070866)",
    },

    -- Blur is what makes the bar and menus read as glass over the wallpaper.
    -- brightness < 1 keeps the warmth from blooming out behind light text.
    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      noise = 0.015,
      contrast = 1.05,
      brightness = 0.85,
      vibrancy = 0.20,
      popups = true,
      popups_ignorealpha = 0.4,
    },
  },
})

-- Motion. The stock curves are snappy in a way that suits a high-contrast
-- theme; this one is soft-edged and warm, and the same speed reads as
-- twitchy against it. Everything below is slower with a longer tail, so
-- windows settle rather than snap. Hyprland reloads from the defaults on
-- every theme change, so these revert on their own when the theme does.

-- Long decelerating tail: fast commitment, slow settle. This is the curve
-- that carries the theme's whole feel.
hl.curve("sadieSettle", { type = "bezier", points = { { 0.16, 1 }, { 0.22, 1 } } })
-- A touch of overshoot, used only where a surface grows into place.
hl.curve("sadieRise", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.02 } } })

-- Borders are the theme's copper-to-amber gradient. Crossfading them slowly
-- makes focus changes read as the light moving rather than a colour swap.
hl.animation({ leaf = "border", enabled = true, speed = 3.2, bezier = "sadieSettle" })

hl.animation({ leaf = "windows", enabled = true, speed = 3.2, bezier = "sadieSettle" })
-- popin from 92% rather than the stock 87%: less scale distance, so the
-- rounded corners and shadow do not visibly stretch on the way in.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, bezier = "sadieRise", style = "popin 92%" })
-- Out stays quick. A slow dismissal feels like lag, not grace.
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.8, bezier = "linear", style = "popin 94%" })

-- Layers are the blurred glass surfaces. Fading rather than popping keeps
-- the blur from swimming as the surface resizes underneath it.
hl.animation({ leaf = "layers", enabled = true, speed = 3.2, bezier = "sadieSettle" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.4, bezier = "sadieSettle", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.2, bezier = "linear", style = "fade" })

hl.animation({ leaf = "fade", enabled = true, speed = 2.6, bezier = "sadieSettle" })

-- The base is dark enough that full-opacity terminals read as flat cutouts.
-- A whisper of transparency lets the wallpaper's warmth sit underneath.
o.window({ tag = "terminal" }, { opacity = "0.96 0.92" })

-- Blur the shell's own layers. Without these rules the translucency set in
-- shell.*.toml would just show the wallpaper through sharply; Omarchy ships
-- no blur layerrules of its own. ignore_alpha keeps the blur from bleeding
-- out past the rounded corners of each surface.
hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-network-qr)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.2,
})

-- Keep the palette in step with the wallpaper. Background changes fire no
-- hook in Omarchy, so a small watcher follows the background symlink instead.
-- It is a singleton and exits by itself once this theme is deactivated.
-- Referenced by source path on purpose: the copy of this theme under
-- ~/.local/state is rebuilt on every theme change.
hl.exec_cmd(
  "$HOME/.config/omarchy/themes/sadie-my-love/bin/palette-watcher"
)
