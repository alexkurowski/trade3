#+private
package game

import rl "vendor:raylib"

render_begin_3d :: proc() {
  rl.BeginMode3D(g.camera.c3d)
  rl.BeginShaderMode(assets.shaders.base)
}

render_end_3d :: proc() {
  rl.EndShaderMode()
  rl.EndMode3D()
}

render_begin_2d :: proc() {
  // rl.BeginShaderMode(assets.shaders.base)
}

render_end_2d :: proc() {
  // rl.EndShaderMode()
  // rl.EndMode2D()
}
