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

