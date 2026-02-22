#+private file
package ui

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:strings"
import "core:unicode/utf8"
import clay "deps:clay-odin"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

texture: rl.Texture2D
shader: rl.Shader

@(private)
init_raylib_implementation :: proc(width, height: f32) {
  texture = rl.LoadTexture("assets/textures/icons.png")
  shader = rl.LoadShader(nil, "assets/shaders/gl330/ui_fragment.glsl")
  min_memory_size := clay.MinMemorySize()
  memory := make([^]u8, min_memory_size)
  arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(uint(min_memory_size), memory)
  clay.Initialize(arena, {width, height}, {handler = error_handler})
  clay.SetMeasureTextFunction(measure_text_ascii, nil)
}

@(private)
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

  font := fonts[TextFont(config.fontId)][config.fontSize]
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

  font := fonts[TextFont(config.fontId)][config.fontSize]
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

@(private)
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
      font := fonts[TextFont(config.fontId)][config.fontSize]
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
      image_data := cast(^UIImageData)config.imageData
      index := image_data.index

      tint := config.backgroundColor
      if tint == 0 do tint = {255, 255, 255, 255}

      rl.DrawTexturePro(
        texture,
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

      // if draw_gradient {
      //   draw_rect_gradient(
      //     bounds.x,
      //     bounds.y,
      //     bounds.width,
      //     bounds.height,
      //     [3]clay.Color {
      //       color.window_background_start,
      //       color.window_background_middle,
      //       color.window_background_end,
      //     },
      //   )
      // } else if draw_rounded {
      //   radius: f32 = (config.cornerRadius.topLeft * 2) / min(bounds.width, bounds.height)
      //   draw_rect_rounded(
      //     bounds.x,
      //     bounds.y,
      //     bounds.width,
      //     bounds.height,
      //     radius,
      //     config.backgroundColor,
      //   )
      // } else {
      //   draw_rect(bounds.x, bounds.y, bounds.width, bounds.height, config.backgroundColor)
      // }

      draw_rect(bounds.x, bounds.y, bounds.width, bounds.height, config.backgroundColor)
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

get_texture_source_rect :: proc(index: i32) -> rl.Rectangle {
  size :: 32
  cols :: 32
  x := f32((index % cols) * size)
  y := f32((index / cols) * size)
  return rl.Rectangle{x = x, y = y, width = f32(size), height = f32(size)}
}

clay_color_to_rl_color :: #force_inline proc(color: clay.Color) -> rl.Color {
  return {u8(color.r), u8(color.g), u8(color.b), u8(color.a)}
}

