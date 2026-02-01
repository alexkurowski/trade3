#+private file
package game

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import "core:unicode/utf8"
import clay "deps:clay-odin"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"


// #region Types
UIImageData :: struct {
  index: int,
}

UIWindowResizableDirection :: enum {
  None,
  Horizontal,
  Vertical,
  Both,
}

UIWindowResizingOrigin :: enum {
  None,
  Right,
  TopRight,
  Top,
  TopLeft,
  Left,
  BottomLeft,
  Bottom,
  BottomRight,
}

UIWindow :: struct {
  should_close:    bool,
  pressed:         bool,
  dragging:        bool,
  resizable:       UIWindowResizableDirection,
  resizing_origin: UIWindowResizingOrigin,
  hovering_origin: UIWindowResizingOrigin,
  position:        Vec2,
  size:            Size,
}
// #endregion


// #region UI load/unload
@(private)
ui_load :: proc(width, height: f32) {
  prepare_colors()
  prepare_sprites()
  load_fonts_from_disk()
  create_font_variants_for_ui()
  init_raylib_implementation(width, height)

  window_width = width
  window_height = height
}

@(private)
ui_unload :: proc() {
  unload_raylib_implementation()
  unload_fonts()
}

@(private)
ui_update :: proc() {
  hovering = false

  mouse_position := rl.GetMousePosition()
  clay.SetPointerState(
    {mouse_position.x, mouse_position.y},
    rl.IsMouseButtonDown(.LEFT) || rl.IsMouseButtonDown(.RIGHT),
  )
  clay.UpdateScrollContainers(false, rl.GetMouseWheelMoveV(), time.dt)

  {
    dpi := rl.GetWindowScaleDPI()
    new_width := f32(rl.GetRenderWidth()) / dpi.x
    new_height := f32(rl.GetRenderHeight()) / dpi.x
    if new_width != window_width || new_height != window_height {
      window_width = new_width
      window_height = new_height
      clay.SetLayoutDimensions({window_width, window_height})
    }
  }

  // Clay debug toggle
  if rl.IsKeyDown(.LEFT_ALT) &&
     (rl.IsKeyDown(.LEFT_SUPER) || rl.IsKeyDown(.LEFT_CONTROL)) &&
     rl.IsKeyPressed(.I) {
    clay.SetDebugModeEnabled(!clay.IsDebugModeEnabled())
  }
}

@(private)
ui_begin :: proc() {
  clay.BeginLayout()
}

@(private)
ui_end :: proc() {
  // if str, ok := tooltip.?; ok {
  //   draw_tooltip(str)
  // }
  layout := clay.EndLayout()
  render(&layout)
}
// #endregion


// #region Colors
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
// #endregion


// #region Fonts
@(private)
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
// #endregion


// #region UI option structs
@(private = "file")
UserDataType :: enum u8 {
  PanelGradient = 0,
}
ClayUserDataType :: struct {
  type: UserDataType,
}
panel_gradient := ClayUserDataType {
  type = .PanelGradient,
}


// ## UI sprites
SpriteType :: enum u8 {
  Close,
  Cog,
  Play,
  FFPlay,
  FFFPlay,
  Pause,
  Dropdown,
  CaretLeft,
  CaretRight,
  DoubleCaretLeft,
  DoubleCaretRight,
  Skip01,
  Skip02,
  Skip03,
  Skip04,
  Skip05,
  WindowHoverRight,
  WindowHoverTopRight,
  WindowHoverTop,
  WindowHoverTopLeft,
  WindowHoverLeft,
  WindowHoverBottomLeft,
  WindowHoverBottom,
  WindowHoverBottomRight,
}
UserDataSprite :: struct {
  index: int,
}
ui_sprite := map[SpriteType]UserDataSprite{}
prepare_sprites :: proc() {
  for sprite in SpriteType {
    ui_sprite[sprite] = UserDataSprite {
      index = int(sprite),
    }
  }
}
// #endregion


// #region Raylib implementation
texture: rl.Texture2D
shader: rl.Shader

init_raylib_implementation :: proc(width, height: f32) {
  texture = rl.LoadTexture("assets/textures/ui.png")
  shader = rl.LoadShader(nil, "assets/shaders/gl330/ui_fragment.glsl")
  min_memory_size := clay.MinMemorySize()
  memory := make([^]u8, min_memory_size)
  arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(uint(min_memory_size), memory)
  clay.Initialize(arena, {width, height}, {handler = error_handler})
  clay.SetMeasureTextFunction(measure_text_ascii, nil)
}

unload_raylib_implementation :: proc() {
  rl.UnloadTexture(texture)
  rl.UnloadShader(shader)
}

error_handler :: proc "c" (errorData: clay.ErrorData) {
  context = runtime.default_context()
  fmt.printf("%#v", errorData)
}

measure_text_unicode :: proc "c" (
  text: clay.StringSlice,
  config: ^clay.TextElementConfig,
  userData: rawptr,
) -> clay.Dimensions {
  // Needed for grapheme_count
  context = runtime.default_context()

  line_width: f32 = 0

  font := fonts[FontVariant(config.fontId)].font
  text_str := string(text.chars[:text.length])

  // This function seems somewhat expensive, if you notice performance issues, you could assume
  // - 1 codepoint per visual character (no grapheme clusters), where you can get the length from the loop
  // - 1 byte per visual character (ascii), where you can get the length with `text.length`
  // see `measure_text_ascii`
  grapheme_count, _, _ := utf8.grapheme_count(text_str)

  for letter in text_str {
    glyph_index := rl.GetGlyphIndex(font, letter)

    glyph := font.glyphs[glyph_index]

    if glyph.advanceX != 0 {
      line_width += f32(glyph.advanceX)
    } else {
      line_width += font.recs[glyph_index].width + f32(font.glyphs[glyph_index].offsetX)
    }
  }

  scaleFactor := f32(config.fontSize) / f32(font.baseSize)

  // Note:
  //   I'd expect this to be `grapheme_count - 1`,
  //   but that seems to be one letterSpacing too small
  //   maybe that's a raylib bug, maybe that's Clay?
  total_spacing := f32(grapheme_count) * f32(config.letterSpacing)

  return {width = line_width * scaleFactor + total_spacing, height = f32(config.fontSize)}
}

measure_text_ascii :: proc "c" (
  text: clay.StringSlice,
  config: ^clay.TextElementConfig,
  userData: rawptr,
) -> clay.Dimensions {
  line_width: f32 = 0

  font := fonts[FontVariant(config.fontId)].font
  text_str := string(text.chars[:text.length])

  for i in 0 ..< len(text_str) {
    glyph_index := text_str[i] - 32

    glyph := font.glyphs[glyph_index]

    if glyph.advanceX != 0 {
      line_width += f32(glyph.advanceX)
    } else {
      line_width += font.recs[glyph_index].width + f32(font.glyphs[glyph_index].offsetX)
    }
  }

  scaleFactor := f32(config.fontSize) / f32(font.baseSize)

  // Note:
  //   I'd expect this to be `len(text_str) - 1`,
  //   but that seems to be one letterSpacing too small
  //   maybe that's a raylib bug, maybe that's Clay?
  total_spacing := f32(len(text_str)) * f32(config.letterSpacing)

  return {width = line_width * scaleFactor + total_spacing, height = f32(config.fontSize)}
}

render :: proc(render_commands: ^clay.ClayArray(clay.RenderCommand)) {
  rl.BeginShaderMode(shader)

  for i in 0 ..< render_commands.length {
    render_command := clay.RenderCommandArray_Get(render_commands, i)
    bounds := render_command.boundingBox

    switch render_command.commandType {
    case .None: // None
    case .Text:
      config := render_command.renderData.text

      text := string(config.stringContents.chars[:config.stringContents.length])
      cstr := strings.clone_to_cstring(text, context.temp_allocator)
      font := fonts[FontVariant(config.fontId)].font
      rl.DrawTextEx(
        font,
        cstr,
        {bounds.x, bounds.y},
        f32(config.fontSize),
        f32(config.letterSpacing),
        clay_color_to_rl_color(config.textColor),
      )
    case .Image:
      config := render_command.renderData.image
      user_data := render_command.userData

      index := 0
      if user_data != nil {
        sprite := cast(^UserDataSprite)user_data
        index = sprite.index
      }

      tint := config.backgroundColor
      if tint == 0 do tint = {255, 255, 255, 255}

      imageTexture := (^rl.Texture2D)(config.imageData)
      rl.DrawTexturePro(
        imageTexture^,
        source = get_texture_source_rect(index),
        dest = {bounds.x, bounds.y, bounds.width, bounds.height},
        origin = {0, 0},
        rotation = 0,
        tint = clay_color_to_rl_color(tint),
      )
    case .ScissorStart:
      rl.BeginScissorMode(
        i32(math.round(bounds.x)),
        i32(math.round(bounds.y)),
        i32(math.round(bounds.width)),
        i32(math.round(bounds.height)),
      )
    case .ScissorEnd:
      rl.EndScissorMode()
    case .Rectangle:
      config := render_command.renderData.rectangle
      user_data := render_command.userData

      draw_rounded :=
        config.cornerRadius.topLeft > 0 ||
        config.cornerRadius.topRight > 0 ||
        config.cornerRadius.bottomLeft > 0 ||
        config.cornerRadius.bottomRight > 0
      draw_gradient :=
        user_data != nil && (cast(^ClayUserDataType)user_data).type == .PanelGradient

      if draw_gradient {
        draw_rect_gradient(
          bounds.x,
          bounds.y,
          bounds.width,
          bounds.height,
          [3]clay.Color {
            color.window_background_start,
            color.window_background_middle,
            color.window_background_end,
          },
        )
      } else if draw_rounded {
        radius: f32 = (config.cornerRadius.topLeft * 2) / min(bounds.width, bounds.height)
        draw_rect_rounded(
          bounds.x,
          bounds.y,
          bounds.width,
          bounds.height,
          radius,
          config.backgroundColor,
        )
      } else {
        draw_rect(bounds.x, bounds.y, bounds.width, bounds.height, config.backgroundColor)
      }
    case .Border:
      config := render_command.renderData.border
      // Left border
      if config.width.left > 0 {
        draw_rect(
          bounds.x,
          bounds.y + config.cornerRadius.topLeft,
          f32(config.width.left),
          bounds.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft,
          config.color,
        )
      }
      // Right border
      if config.width.right > 0 {
        draw_rect(
          bounds.x + bounds.width - f32(config.width.right),
          bounds.y + config.cornerRadius.topRight,
          f32(config.width.right),
          bounds.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight,
          config.color,
        )
      }
      // Top border
      if config.width.top > 0 {
        draw_rect(
          bounds.x + config.cornerRadius.topLeft,
          bounds.y,
          bounds.width - config.cornerRadius.topLeft - config.cornerRadius.topRight,
          f32(config.width.top),
          config.color,
        )
      }
      // Bottom border
      if config.width.bottom > 0 {
        draw_rect(
          bounds.x + config.cornerRadius.bottomLeft,
          bounds.y + bounds.height - f32(config.width.bottom),
          bounds.width - config.cornerRadius.bottomLeft - config.cornerRadius.bottomRight,
          f32(config.width.bottom),
          config.color,
        )
      }

      // Rounded Borders
      if config.cornerRadius.topLeft > 0 {
        draw_arc(
          bounds.x + config.cornerRadius.topLeft,
          bounds.y + config.cornerRadius.topLeft,
          config.cornerRadius.topLeft - f32(config.width.top),
          config.cornerRadius.topLeft,
          180,
          270,
          config.color,
        )
      }
      if config.cornerRadius.topRight > 0 {
        draw_arc(
          bounds.x + bounds.width - config.cornerRadius.topRight,
          bounds.y + config.cornerRadius.topRight,
          config.cornerRadius.topRight - f32(config.width.top),
          config.cornerRadius.topRight,
          270,
          360,
          config.color,
        )
      }
      if config.cornerRadius.bottomLeft > 0 {
        draw_arc(
          bounds.x + config.cornerRadius.bottomLeft,
          bounds.y + bounds.height - config.cornerRadius.bottomLeft,
          config.cornerRadius.bottomLeft - f32(config.width.top),
          config.cornerRadius.bottomLeft,
          90,
          180,
          config.color,
        )
      }
      if config.cornerRadius.bottomRight > 0 {
        draw_arc(
          bounds.x + bounds.width - config.cornerRadius.bottomRight,
          bounds.y + bounds.height - config.cornerRadius.bottomRight,
          config.cornerRadius.bottomRight - f32(config.width.bottom),
          config.cornerRadius.bottomRight,
          0.1,
          90,
          config.color,
        )
      }
    case clay.RenderCommandType.Custom:
    // Implement custom element rendering here
    }
  }

  rl.EndShaderMode()
}

draw_arc :: proc(
  x, y: f32,
  inner_rad, outer_rad: f32,
  start_angle, end_angle: f32,
  color: clay.Color,
) {
  rl.DrawRing(
    {math.round(x), math.round(y)},
    math.round(inner_rad),
    outer_rad,
    start_angle,
    end_angle,
    10,
    clay_color_to_rl_color(color),
  )
}

draw_rect :: proc(x, y, w, h: f32, color: clay.Color) {
  rl.DrawRectangle(
    i32(math.round(x)),
    i32(math.round(y)),
    i32(math.round(w)),
    i32(math.round(h)),
    clay_color_to_rl_color(color),
  )
}

draw_rect_gradient :: proc(x, y, w, h: f32, colors: [3]clay.Color) {
  rx, ry, rw, rh := math.round(x), math.round(y), math.round(w), math.round(h)

  top_left := Vec2{rx, ry}
  top_right := Vec2{rx + rw, ry}
  bottom_left := Vec2{rx, ry + rh}
  bottom_right := Vec2{rx + rw, ry + rh}
  c1 := colors[0]
  c2 := colors[1]
  c3 := colors[2]

  gl.Begin(gl.TRIANGLES)

  gl.Color4ub(u8(c1.r), u8(c1.g), u8(c1.b), u8(c1.a))
  gl.Vertex2f(top_left.x, top_left.y)
  gl.Color4ub(u8(c2.r), u8(c2.g), u8(c2.b), u8(c2.a))
  gl.Vertex2f(bottom_left.x, bottom_left.y)
  gl.Color4ub(u8(c3.r), u8(c3.g), u8(c3.b), u8(c3.a))
  gl.Vertex2f(bottom_right.x, bottom_right.y)

  gl.Color4ub(u8(c1.r), u8(c1.g), u8(c1.b), u8(c1.a))
  gl.Vertex2f(top_left.x, top_left.y)
  gl.Color4ub(u8(c3.r), u8(c3.g), u8(c3.b), u8(c3.a))
  gl.Vertex2f(bottom_right.x, bottom_right.y)
  gl.Color4ub(u8(c2.r), u8(c2.g), u8(c2.b), u8(c2.a))
  gl.Vertex2f(top_right.x, top_right.y)

  gl.End()
}

draw_rect_rounded :: proc(x, y, w, h: f32, radius: f32, color: clay.Color) {
  rl.DrawRectangleRounded({x, y, w, h}, radius, 8, clay_color_to_rl_color(color))
}

get_texture_source_rect :: proc(index: int) -> rl.Rectangle {
  sprite_size :: 64
  cols :: 16
  x := f32((index % cols) * sprite_size)
  y := f32((index / cols) * sprite_size)
  return rl.Rectangle{x = x, y = y, width = f32(sprite_size), height = f32(sprite_size)}
}

clay_color_to_rl_color :: #force_inline proc(color: clay.Color) -> rl.Color {
  return {u8(color.r), u8(color.g), u8(color.b), u8(color.a)}
}
// #endregion


// #region Components
text_const :: proc($str: string, variant: FontVariant = .Regular16, _: bool = true) {
  clay.Text(str, &font_configs[variant])
}
text_var :: proc(str: string, variant: FontVariant = .Regular16) {
  clay.TextDynamic(str, &font_configs[variant])
}
@(private)
text :: proc {
  text_const,
  text_var,
}

draw_tooltip :: proc(str: string) {
  mouse_position := rl.GetMousePosition()
  if UI()({
    layout = {sizing = sizing_fit, padding = padding(8, 4)},
    backgroundColor = color.window_background_end,
    border = {width = border(1), color = color.window_border},
    floating = {attachTo = .Root, offset = {mouse_position.x + 10, mouse_position.y + 10}},
  }) {
    text(str)
  }
}

spacer :: proc() {
  UI()({layout = {sizing = {grow(), fit()}}})
}
// #endregion
