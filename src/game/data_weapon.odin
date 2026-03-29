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
  sway:   struct {
    current:  f32,
    min:      f32,
    max:      f32,
    increase: f32,
    decrease: f32,
    cooldown: f32,
    interval: f32,
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
  g.player.weapon.sway.max = 10
  g.player.weapon.sway.min = 2
  g.player.weapon.sway.current = g.player.weapon.sway.min
  g.player.weapon.sway.increase = 1
  g.player.weapon.sway.decrease = 5
  g.player.weapon.sway.cooldown = 0
  g.player.weapon.sway.interval = 1
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

weapon_sway_increase :: proc(continuous: bool = false) {
  s := &g.player.weapon.sway
  s.cooldown = s.interval
  if continuous {
    s.current += s.increase * time.wdt
  } else {
    s.current += s.increase
  }
  if s.current > s.max {
    s.current = s.max
  }
}

weapon_sway_decrease :: proc() {
  s := &g.player.weapon.sway
  if s.cooldown < 0 {
    if s.current > s.min {
      s.current -= s.decrease * time.wdt
    }
  } else {
    s.cooldown -= time.wdt
  }
}

get_weapon_aim_radius :: proc(position: Vec3) -> f32 {
  distance := length(position - g.player.aim.position)
  radius := distance * sin(g.player.weapon.sway.current * DEG_TO_RAD)
  return radius
}

