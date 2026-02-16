package ui

import "core:math"
import "core:math/rand"
import clay "deps:clay-odin"
import rl "vendor:raylib"

color: struct {
  black:                    clay.Color,
  white:                    clay.Color,
  dark:                     clay.Color,
  light:                    clay.Color,
  gray:                     clay.Color,
  light_gray:               clay.Color,
  yellow:                   clay.Color,
  transparent:              clay.Color,
  //
  window_background_start:  clay.Color,
  window_background_middle: clay.Color,
  window_background_end:    clay.Color,
  window_border:            clay.Color,
  button:                   clay.Color,
  button_hover:             clay.Color,
  text:                     clay.Color,
  text_dim:                 clay.Color,
} = {
  black       = {8, 8, 8, 255},
  white       = {250, 250, 250, 255},
  dark        = {26, 26, 26, 255},
  light       = {224, 224, 224, 255},
  gray        = {40, 47, 56, 255},
  light_gray  = {49, 59, 69, 255},
  yellow      = {255, 221, 0, 255},
  transparent = {0, 0, 0, 0},
}
prepare_colors :: proc() {
  color.window_background_start = alpha(color.dark, 242)
  color.window_background_middle = alpha(color.dark, 217)
  color.window_background_end = alpha(color.dark, 191)
  color.window_border = alpha(color.light, 26)
  color.button = color.dark
  color.button_hover = color.gray
  color.text = color.light
  color.text_dim = color.light - [4]f32{102, 102, 102, 0}
}
alpha_clay :: proc(c: clay.Color, a: f32) -> clay.Color {
  return clay.Color{c.r, c.g, c.b, a}
}
alpha_rl :: proc(c: rl.Color, a: u8) -> rl.Color {
  return rl.Color{c.r, c.g, c.b, a}
}
alpha :: proc {
  alpha_clay,
  alpha_rl,
}
vary :: proc(c: rl.Color, amount: i32) -> rl.Color {
  r := math.clamp(i16(c.r) + i16(rand.int32_range(-amount, amount + 1)), 0, 255)
  g := math.clamp(i16(c.g) + i16(rand.int32_range(-amount, amount + 1)), 0, 255)
  b := math.clamp(i16(c.b) + i16(rand.int32_range(-amount, amount + 1)), 0, 255)
  return rl.Color{u8(r), u8(g), u8(b), c.a}
}

ColorRGB :: clay.Color
ColorHSL :: struct {
  h: f32,
  s: f32,
  l: f32,
  a: f32,
}
to_hsl :: proc(c: ColorRGB) -> ColorHSL {
  r := c.r / 255
  g := c.g / 255
  b := c.b / 255
  a := c.a

  max := max(r, max(g, b))
  min := min(r, min(g, b))
  h, s: f32
  l := (max + min) / 2

  if min == max {
    h = 0
    s = 0
  } else {
    d := max - min
    if l > 0.5 {
      s = d / (2 - max - min)
    } else {
      s = d / (max + min)
    }

    if max == r {
      h = (g - b) / d + (g < b ? 6 : 0)
    } else if max == g {
      h = (b - r) / d + 2
    } else if max == b {
      h = (r - g) / d + 4
    }
    h /= 6
  }

  return ColorHSL{h, s, l, a}
}
to_rgb :: proc(hsl: ColorHSL) -> ColorRGB {
  one_third :: f32(1) / f32(3)

  q: f32
  h := hsl.h
  s := hsl.s
  l := hsl.l
  a := hsl.a

  if hsl.l < 0.5 {
    q = l * (1 + s)
  } else {
    q = l + s - l * s
  }
  p := 2 * l - q

  hue_to_rgb :: proc(p: f32, q: f32, t: f32) -> f32 {
    one_sixth :: f32(1) / f32(6)
    one_half :: f32(1) / f32(2)
    two_thirds :: f32(2) / f32(3)

    t := t
    if t < 0 {
      t += 1
    }
    if t > 1 {
      t -= 1
    }

    if t < one_sixth {
      return p + (q - p) * 6 * t
    }
    if t < one_half {
      return q
    }
    if t < two_thirds {
      return p + (q - p) * (two_thirds - t) * 6
    }
    return p
  }

  r := hue_to_rgb(p, q, h + one_third)
  g := hue_to_rgb(p, q, h)
  b := hue_to_rgb(p, q, h - one_third)

  r = clamp(r * 255, 0, 255)
  g = clamp(g * 255, 0, 255)
  b = clamp(b * 255, 0, 255)

  return ColorRGB{r, g, b, a}
}
make_brighter :: proc(c: ColorRGB, amount: f32) -> ColorRGB {
  hsl := to_hsl(c)
  hsl.l = clamp(hsl.l + amount, 0.0, 1.0)
  return to_rgb(hsl)
}

//
//
//

FontVariant :: enum u8 {
  Regular16,
  Regular16hl,
  Regular16dim,
  Regular20,
  Regular20hl,
  Regular20dim,
  Regular24,
  Regular24hl,
  Regular24dim,
  Bold16,
  Bold16hl,
  Bold16dim,
  Bold20,
  Bold20hl,
  Bold20dim,
  Bold24,
  Bold24hl,
  Bold24dim,
  Title14,
  Title14hl,
  Title18,
  Title18hl,
}

FontVariantDefinition :: struct {
  ttf:   int,
  size:  u16,
  color: int,
}
font_variant_definitions: [FontVariant]FontVariantDefinition = {
  .Regular16    = {0, 16, 0},
  .Regular16hl  = {0, 16, 1},
  .Regular16dim = {0, 16, 2},
  .Regular20    = {0, 20, 0},
  .Regular20hl  = {0, 20, 1},
  .Regular20dim = {0, 20, 2},
  .Regular24    = {0, 24, 0},
  .Regular24hl  = {0, 24, 1},
  .Regular24dim = {0, 24, 2},
  .Bold16       = {1, 16, 0},
  .Bold16hl     = {1, 16, 1},
  .Bold16dim    = {1, 16, 2},
  .Bold20       = {1, 20, 0},
  .Bold20hl     = {1, 20, 1},
  .Bold20dim    = {1, 20, 2},
  .Bold24       = {1, 24, 0},
  .Bold24hl     = {1, 24, 1},
  .Bold24dim    = {1, 24, 2},
  .Title14      = {2, 14, 0},
  .Title14hl    = {2, 14, 1},
  .Title18      = {2, 18, 0},
  .Title18hl    = {2, 18, 1},
}
font_ttfs := [3]cstring {
  "assets/fonts/Sofia-Regular.ttf",
  "assets/fonts/Sofia-Bold.ttf",
  "assets/fonts/Anta-Regular.ttf",
}

ClayFont :: struct {
  id:    u16,
  font:  rl.Font,
  size:  u16,
  color: clay.Color,
}
fonts := [FontVariant]ClayFont{}

load_fonts_from_disk :: proc() {
  font_colors := [3]clay.Color{color.text, color.yellow, color.text_dim}

  def: FontVariantDefinition
  for font in FontVariant {
    def = font_variant_definitions[font]
    fonts[font] = ClayFont {
      id    = u16(font),
      font  = rl.LoadFontEx(font_ttfs[def.ttf], i32(def.size * 2), nil, 0),
      size  = def.size,
      color = font_colors[def.color],
    }
  }
}

unload_fonts :: proc() {
  for font in fonts {
    rl.UnloadFont(font.font)
  }
}

font_configs: [FontVariant]clay.TextElementConfig

create_font_variants_for_ui :: proc() {
  for font in fonts {
    font_configs[FontVariant(font.id)] = clay.TextElementConfig {
      fontId    = font.id,
      fontSize  = font.size,
      textColor = font.color,
    }
  }
}
