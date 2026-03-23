package game

import cont "containers"
import "physics"
import "render"
import "text"
import "ui"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

AREA_LIMIT :: 25
PLAYER_AREA_LIMIT :: AREA_LIMIT * 0.75
BULLET_AREA_LIMIT :: AREA_LIMIT * 2
ENEMY_SPAWN_DISTANCE :: AREA_LIMIT * 1.5

GameMemory :: struct {
  state:          GameState,
  location:       Location,
  entities:       cont.Array(Entity, ID, 2048),
  body_to_entity: map[physics.BID]ID,
  bullets:        cont.Pool(Bullet, 2048),
  collectables:   cont.Pool(Collectable, 2048),
  events:         EventQueue,
  player:         struct {
    id:        ID,
    aim:       Vec3,
    mouse:     Vec2,
    weapon:    PlayerWeapon,
    inventory: Inventory,
  },
  progress:       Progress,
  enemy_count:    u32,
  debug:          bool,
}

g: ^GameMemory

@(export)
open_window :: proc() {
  rl.SetConfigFlags({.MSAA_4X_HINT, .WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

  rl.InitWindow(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT, "Garden")

  // rl.SetTargetFPS(90)
  rl.SetExitKey(.ESCAPE)
  gl.EnableDepthTest()
  gl.EnableColorBlend()
  gl.SetClipPlanes(0.5, 500)

  // TODO: draw static loading screen
}

@(export)
close_window :: proc() {
  rl.CloseWindow()
}

@(export)
is_running :: proc() -> bool {
  return !rl.WindowShouldClose() && g.state != .Quit
}

@(export)
load :: proc() {
  g = new(GameMemory)
  g.debug = true // DBG
  g.progress.pickup_radius = 2

  text.load()
  render.load()
  ui.load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)
  physics.load()

  subscribe_events()
}

@(export)
unload :: proc() {
  physics.unload()
  ui.unload()
  render.unload()
  text.unload()

  free(g)
}

@(export)
update :: proc() {
  rl.BeginDrawing()
  defer rl.EndDrawing()

  frame_begin()
  state_update()
  state_transition()
  frame_end()

  free_all(context.temp_allocator)
}

@(private = "file")
frame_begin :: proc() {
  render.begin(time.dt)
  ui.begin(time.dt)

  rl.ClearBackground(rl.BLACK)
}

@(private = "file")
frame_end :: proc() {
  render.begin_3d()
  render.draw_3d()

  if g.debug {
    physics.draw_debug()
  }

  render.end_3d()

  render.begin_2d()
  render.draw_2d()
  ui.end()
  render.end_2d()

  if rl.IsKeyPressed(.SLASH) {
    g.debug = !g.debug
  }
  if g.debug {
    rl.DrawFPS(0, 0)
  }
}

