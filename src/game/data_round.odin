#+private
package game

Round :: struct {
  age:             f32,
  tick_timeout:    f32,
  tick_interval:   f32,
  enemy_count:     u32,
  max_enemy_count: u32,
  spawn_timeout:   f32,
  spawn_interval:  f32,
  crate_timeout:   f32,
  crate_interval:  f32,
}

reset_round :: proc() {
  g.round.age = 0
  g.round.tick_interval = 10
  g.round.tick_timeout = g.round.tick_interval
  g.round.max_enemy_count = 5
  g.round.spawn_timeout = 0
  g.round.spawn_interval = 0.5
  g.round.crate_interval = 5
  g.round.crate_timeout = g.round.crate_interval
}

