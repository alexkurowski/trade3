#+private
package game

import "core:fmt"
import "render"
import "text"
import "ui"
import rl "vendor:raylib"

RESOURCE_LABELS := [ResourceKind]string {
  .A = "A",
  .B = "B",
  .C = "C",
  .D = "D",
  .E = "E",
  .F = "F",
}

@(private = "file")
camera: Vec2

state_upgrade_ready :: proc() {
  camera.x = f32(rl.GetScreenWidth() / 2) - 12
  camera.y = f32(rl.GetScreenHeight() / 2) - 12
  rl.ShowCursor()
}

state_upgrade :: proc() {
  draw_upgrades()

  if rl.IsMouseButtonDown(.RIGHT) {
    camera += rl.GetMouseDelta()
  }

  if UI()(ui_root) {
    draw_resources()
    draw_buttons()
  }

  upgrade_debug()
}

draw_upgrades :: proc() {
  @(static) mouse_position: Vec2
  mouse_position = rl.GetMousePosition() - camera
  is_hover :: proc(u: ^Upgrade) -> bool {
    SIZE :: 24
    return(
      mouse_position.x > u.position.x &&
      mouse_position.x < u.position.x + SIZE &&
      mouse_position.y > u.position.y &&
      mouse_position.y < u.position.y + SIZE \
    )
  }

  for &u in g.progress.upgrades.items {
    if is_none(u.id) do continue
    if !upgrade_is_known(&u) do continue

    state: render.UpgradeState = .Normal
    if upgrade_is_complete(&u) {
      state = .Complete
    } else if is_hover(&u) {
      state = .Hover
    } else if upgrade_is_active(&u) {
      state = .Active
    } else {
      state = .Normal
    }

    if state == .Hover && rl.IsMouseButtonPressed(.LEFT) {
      if upgrade_can_afford(&u) {
        upgrade_purchase(&u)
      }
    }

    render.upgrade(.Star, u.position + camera, state = state, current = u.current, max = u.max)
  }
}

draw_resources :: proc() {
  if UI()({
    layout = {layoutDirection = .TopToBottom, padding = {8, 8, 8, 8}, childGap = 8},
    floating = {attachTo = .Root, attachment = {element = .RightTop, parent = .RightTop}},
  }) {
    for kind in ResourceKind {
      ui.text(
        fmt.tprintf(
          "%v = %s",
          RESOURCE_LABELS[kind],
          text.format_number(g.progress.inventory.resources[kind]),
        ),
      )
    }
  }
}

draw_buttons :: proc() {
  btn :: proc(label: string) -> bool {
    hover, click: bool

    if UI()({}) {
      hover = is_hovered()
      if UI()({
        layout = {padding = {8, 8, 4, 4}},
        backgroundColor = hover ? {40, 40, 40, 255} : {10, 10, 10, 255},
      }) {
        click = hover && is_pressed()
        ui.text(label)
      }
    }
    return click
  }

  if UI()({
    layout = {layoutDirection = .LeftToRight, padding = {8, 8, 8, 8}, childGap = 8},
    floating = {attachTo = .Root, attachment = {element = .RightBottom, parent = .RightBottom}},
  }) {
    if btn("EXIT") {
      set_state(.Quit)
    }
    if btn("DEPLOY") {
      set_state(.Run)
    }
  }
}

@(private = "file")
upgrade_debug :: proc() {
  x := 1
  if rl.IsKeyDown(.LEFT_SHIFT) do x = -1

  if rl.IsKeyDown(.A) do g.progress.inventory.resources[.A] = u64(int(g.progress.inventory.resources[.A]) + x)
  if rl.IsKeyDown(.B) do g.progress.inventory.resources[.B] = u64(int(g.progress.inventory.resources[.B]) + x)
  if rl.IsKeyDown(.C) do g.progress.inventory.resources[.C] = u64(int(g.progress.inventory.resources[.C]) + x)
  if rl.IsKeyDown(.D) do g.progress.inventory.resources[.D] = u64(int(g.progress.inventory.resources[.D]) + x)
  if rl.IsKeyDown(.E) do g.progress.inventory.resources[.E] = u64(int(g.progress.inventory.resources[.E]) + x)
  if rl.IsKeyDown(.F) do g.progress.inventory.resources[.F] = u64(int(g.progress.inventory.resources[.F]) + x)
}

