package physics

import b2 "vendor:box2d"

world: WID

load :: proc() {
  world_def := b2.DefaultWorldDef()
  world_def.gravity = Vec2{0, 0}
  world_def.maximumLinearSpeed = 100
  world = b2.CreateWorld(world_def)

  init_debug_draw()
}

unload :: proc() {
  b2.DestroyWorld(world)
}

update :: proc(dt: f32) {
  b2.World_Step(world, dt, 4)
}

draw_debug :: proc() {
  b2.World_Draw(world, &physics_world_debug)
}

