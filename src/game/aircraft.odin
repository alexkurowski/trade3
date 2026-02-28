#+private
package game

get_orientation :: proc(e: ^Entity) -> f32 {
  return clamp(abs(sin(e.rotation)), 0.2, 1)
}
