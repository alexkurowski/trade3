package ui

import clay "deps:clay-odin"
import rl "vendor:raylib"

TextFont :: enum u8 {
  Regular,
  Bold,
  Title,
}
ttfs := [TextFont]cstring {
  .Regular = "assets/fonts/Sofia-Regular.ttf",
  .Bold    = "assets/fonts/Sofia-Bold.ttf",
  .Title   = "assets/fonts/Anta-Regular.ttf",
}

TextColor :: enum u8 {
  Black,
  White,
}
text_colors := [TextColor]clay.Color {
  .Black = {10, 10, 10, 255},
  .White = {250, 250, 250, 255},
}

FontVariant :: struct {
  font:   rl.Font,
  config: clay.TextElementConfig,
}
font_variants := [TextFont][TextColor]map[u16]FontVariant{}
font_variant_by_id: [64]^FontVariant

load_fonts_from_disk :: proc() {
  sizes :: [?]u16{16, 18, 20, 24, 32, 48, 64}

  id := u16(0)
  for font in TextFont {
    for color in TextColor {
      for size in sizes {
        font_variants[font][color][size] = FontVariant {
          font = rl.LoadFontEx(ttfs[font], i32(size * 2), nil, 0),
          config = clay.TextElementConfig {
            textColor = text_colors[color],
            fontId = id,
            fontSize = size,
          },
        }
        id += 1
      }
    }
  }

  id = 0
  for font in TextFont {
    for color in TextColor {
      for size in sizes {
        font_variant_by_id[id] = &font_variants[font][color][size]
        id += 1
      }
    }
  }
}

unload_fonts :: proc() {
  for fonts_by_font in font_variants {
    for fonts_by_color in fonts_by_font {
      for _, font_variant in fonts_by_color {
        rl.UnloadFont(font_variant.font)
      }
    }
  }
}

text_const :: proc(
  $str: string,
  color: TextColor = .White,
  font: TextFont = .Regular,
  size: u16 = 16,
  _: bool = true,
) {
  cfg := &font_variants[font][color][size]
  clay.Text(str, &cfg.config)
}
text_var :: proc(
  str: string,
  color: TextColor = .White,
  font: TextFont = .Regular,
  size: u16 = 16,
) {
  cfg := &font_variants[font][color][size]
  clay.TextDynamic(str, &cfg.config)
}
text :: proc {
  text_const,
  text_var,
}
