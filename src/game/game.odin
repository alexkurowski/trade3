#+private file
package game

import "core:fmt"
import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  // Reset all boxes
  box.clear(&sectors)
  box.clear(&stations)
  box.clear(&ships)
  box.clear(&characters)

  // Spawn a sector
  box.append(&sectors, Sector{name = make_random_name(), position = to_vec3(rand_offset(10, 50))})

  // Spawn 3 player characters
  for i := 0; i < 3; i += 1 {
    eid, _ := box.append(&characters, Character{name = make_random_full_name()})
    box.append(&player.character_ids, eid)
  }
}

@(private)
game_loop :: proc() {
  draw_character_portraits()
  draw_player_select()
}

draw_character_portraits :: proc() {
  if UI()({
    layout = {
      sizing = sizing_grow,
      layoutDirection = .LeftToRight,
      padding = {8, 8, 8, 8},
      childAlignment = {.Left, .Bottom},
      childGap = 8,
    },
    floating = {attachTo = .Root},
  }) {

    for id in box.every(&player.character_ids) {
      if id == none do continue
      char := box.get(&characters, id)

      if UI()({
        layout = {padding = {8, 8, 6, 6}},
        backgroundColor = is_hovered() ? {75, 75, 75, 255} : {50, 50, 50, 255},
      }) {
        text(char.name)
        if is_clicked() {
          player_select(.Character, char.id)
        }
      }
    }

    text(fmt.tprintf("%.3f", time.wtc), .Regular20dim)
  }
}

draw_player_select :: proc() {
  #partial switch (player.select_kind) {
  case .Character:
    char := box.get(&characters, player.select_id)

    if UI()({
      layout = {
        sizing = sizing_grow,
        layoutDirection = .LeftToRight,
        padding = {8, 8, 8, 8},
        childAlignment = {.Left, .Bottom},
        childGap = 8,
      },
      floating = {attachTo = .Root, offset = {0, -64}},
    }) {
      if UI()({layout = {padding = {8, 8, 6, 6}}, backgroundColor = {50, 50, 50, 255}}) {
        text(fmt.tprintf("Selected: %v", char.name))
      }
    }
  }
}

player_select :: proc(kind: Kind, id: EID) {
  if player.select_kind == kind && player.select_id == id {
    player.select_kind = .None
    player.select_id = none
  } else {
    player.select_kind = kind
    player.select_id = id
  }
}
