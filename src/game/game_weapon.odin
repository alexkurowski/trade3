#+private
package game

Weapon :: struct {
  kind:   WeaponKind,
  ammo:   struct {
    current: u16,
    max:     u16,
  },
  fire:   Cooldown,
  reload: struct {
    duration:  f32,
    qte_start: f32,
    qte_end:   f32,
  },
  spray:  struct {
    angle:     f32,
    max_angle: f32,
    accuracy:  f32,
    stability: f32,
  },
}

WeaponKind :: enum {
  Raycast,
  Projectile,
}

weapon_set_ammo :: proc(w: ^Weapon, value: u16) {
  w.ammo.max = value
  w.ammo.current = w.ammo.max
}

weapon_reload :: proc(w: ^Weapon) {
  w.ammo.current = w.ammo.max
}

