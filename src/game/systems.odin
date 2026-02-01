#+private file
package game

// import "core:fmt"
// import rl "vendor:raylib"

// player: struct {
//   hover_eid: EID,
// }
//
// @(private)
// update_systems :: proc() {
//   player.hover_eid = none
//
//   if is_turn() {
//     // Turn-based logic goes here
//   }
//   update_stations()
//   update_ships()
//   camera_controls()
//   draw_character_portraits()
// }
//
// camera_controls :: proc() {
//   pan: Vec2
//   zoom: f32
//   if rl.IsKeyDown(.LEFT_SHIFT) {
//     zoom = -rl.GetMouseWheelMoveV().y
//   } else {
//     pan = rl.GetMouseWheelMoveV() * 2.5
//   }
//   camera.angle.x += pan.x
//   camera.angle.y -= pan.y
//   camera.distance += zoom
// }
//
// update_stations :: proc() {
//   for &station, idx in components.station.rows {
//     eid := get_entity(&components.station, idx)
//     phys := get_component(&components.physical, eid)
//     if phys != nil {
//       if is_on_screen(phys.position) {
//         if UI()({
//           layout = {layoutDirection = .TopToBottom, sizing = sizing_grow},
//           floating = {attachTo = .Root, offset = get_screen_position(phys.position)},
//         }) {
//           text(station.name, .Regular16dim)
//         }
//       }
//       rl.DrawSphere(phys.position, 2, rl.GREEN)
//     }
//   }
// }
//
// update_ships :: proc() {
//   for &ship, idx in components.ship.rows {
//     eid := get_entity(&components.ship, idx)
//     phys := get_component(&components.physical, eid)
//     if phys != nil {
//       if is_on_screen(phys.position) {
//         render_sprite(0, get_screen_position(phys.position))
//       }
//       rl.DrawSphere(phys.position, 0.5, rl.BLUE)
//       // Draw radius circles
//       for radius := f32(10); radius < 50; radius += 10 {
//         rl.DrawCircle3D(phys.position, radius, Vec3{1, 0, 0}, 90, rl.Fade(rl.WHITE, 0.4))
//       }
//       rl.DrawCircle3D(phys.position, 50, Vec3{1, 0, 0}, 90, rl.Fade(rl.WHITE, 0.6))
//       rl.DrawCircle3D(phys.position, 75, Vec3{1, 0, 0}, 90, rl.Fade(rl.WHITE, 0.4))
//       rl.DrawCircle3D(phys.position, 100, Vec3{1, 0, 0}, 90, rl.Fade(rl.WHITE, 0.6))
//
//     }
//   }
// }
//
// draw_character_portraits :: proc() {
//   character_portrait :: proc(char: ^Character) {
//     if char == nil do return
//     if UI()({
//       layout = {padding = {8, 8, 6, 6}},
//       backgroundColor = is_hovered() ? {75, 75, 75, 255} : {50, 50, 50, 255},
//     }) {
//       text(char.name)
//     }
//   }
//
//   if UI()({
//     layout = {
//       sizing = sizing_grow,
//       layoutDirection = .LeftToRight,
//       padding = {8, 8, 8, 8},
//       childAlignment = {.Left, .Bottom},
//       childGap = 8,
//     },
//     floating = {attachTo = .Root},
//   }) {
//
//     iter: EntityIterator
//     iterate_view(&iter, &views.player_characters)
//     for iterate_next(&iter) {
//       eid := get_entity(&iter)
//       char := get_component(&components.character, eid)
//       character_portrait(char)
//     }
//
//     text(fmt.tprintf("%.3f", time.wtc), .Regular20dim)
//
//   }
// }
