#+private
package game

PlayerWeapon :: struct {
  kind:   WeaponKind,
  damage: struct {
    current: f32,
  },
  ammo:   struct {
    current: u16,
    max:     u16,
  },
  fire:   struct {
    current:  f32,
    interval: f32,
  },
  reload: struct {
    current:      f32,
    duration:     f32,
    can_qte:      bool,
    qte_start:    f32,
    qte_duration: f32,
  },
  spray:  struct {
    current:   f32,
    min:       f32,
    max:       f32,
    accuracy:  f32,
    stability: f32,
  },
}

WeaponKind :: enum {
  Raycast,
  Projectile,
}

reset_weapon :: proc() {
  g.player.weapon.ammo.current = 30
  g.player.weapon.ammo.max = 30
  g.player.weapon.damage.current = 1
  g.player.weapon.fire.interval = 0.2
  g.player.weapon.reload.duration = 1.5
  g.player.weapon.reload.qte_start = 0.66
  g.player.weapon.reload.qte_duration = 0.075
  g.player.weapon.spray.max = 75
  g.player.weapon.spray.min = 10
  g.player.weapon.spray.current = g.player.weapon.spray.min
}

weapon_start_reload :: proc() {
  g.player.weapon.reload.current += time.wdt
  g.player.weapon.reload.can_qte = true
}

weapon_reload :: proc() {
  g.player.weapon.ammo.current = g.player.weapon.ammo.max
}

weapon_is_reloading :: proc() -> bool {
  return g.player.weapon.reload.current > 0
}

weapon_is_reloading_done :: proc() -> bool {
  return g.player.weapon.reload.current >= g.player.weapon.reload.duration
}

weapon_is_in_qte_window :: proc() -> bool {
  w := g.player.weapon
  return(
    w.reload.current >= w.reload.qte_start * w.reload.duration &&
    w.reload.current <=
      w.reload.qte_start * w.reload.duration + w.reload.qte_duration * w.reload.duration \
  )
}

get_weapon_aim_radius :: proc(position: Vec3) -> f32 {
  distance := length(position - g.player.aim.position)
  radius := distance * sin(g.player.weapon.spray.current * DEG_TO_RAD / 2) * 10
  return clamp(radius, g.player.weapon.spray.min, g.player.weapon.spray.max)
}

