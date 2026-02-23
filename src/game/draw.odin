#+private file
package game

import "./ui"

Tab :: enum {
  Mothership,
  Fleet,
  Crew,
}

current_tab: Tab

@(private)
draw_screen :: proc() {
  root_style := Style {
    layout = {
      sizing = {grow(), grow()},
      layoutDirection = .TopToBottom,
      padding = {16, 16, 12, 12},
    },
  }
  if UI()(root_style) {
    tabs()
    ui.text("Hello, World!", font = .Title)

    if button("Click me", .Panda) {
      send_event(.Some, SomeEvent{value = 69420})
    }

    character_box("John")
  }
}

tabs :: proc() {
  if UI()({layout = {sizing = {grow(), fit()}, padding = {8, 8, 4, 4}, childGap = 8}}) {
    if button("Mothership", .Rocket, current_tab == .Mothership) {
      current_tab = .Mothership
    }
    ui.space()
    if button("Fleet", .Sandwich, current_tab == .Fleet) {
      current_tab = .Fleet
    }
    ui.space()
    if button("Crew", .Person_standing, current_tab == .Crew) {
      current_tab = .Crew
    }
  }
}

button :: proc(label: string, icon: ui.Icon, active: bool = false) -> bool {
  hovered: bool
  clicked: bool

  if UI()({}) {
    hovered = is_hover()
    clicked = is_clicked()
    if UI()({
      layout = {padding = {8, 8, 4, 4}, childAlignment = {.Center, .Center}, childGap = 8},
      backgroundColor = hovered || active ? {240, 240, 240, 255} : {0, 0, 0, 0},
    }) {
      ui.icon(icon, hovered || active ? {0, 0, 0, 255} : {240, 240, 240, 255})
      ui.text(label, font = .Regular, size = 18, color = hovered || active ? .Black : .White)
    }
  }

  return clicked
}

character_box :: proc(name: string) {
  container := Style {
    layout = {padding = {8, 8, 8, 8}},
  }

  if UI()(container) {
    ui.text(name)
  }
}

