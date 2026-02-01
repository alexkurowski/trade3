#+private
package game

spawn_station :: proc() -> EID {
  eid, _ := spawn()

  phys, _ := add_component(&components.physical, eid)
  phys.position = to_vec3(rand_offset(5, 10), randf(-5, 5))

  station, _ := add_component(&components.station, eid)
  station.name = make_random_name()

  return eid
}

spawn_ship :: proc() -> EID {
  eid, _ := spawn()

  phys, _ := add_component(&components.physical, eid)
  phys.position = to_vec3(rand_offset(5, 10), randf(-5, 5))

  ship, _ := add_component(&components.ship, eid)
  ship.callsign = make_ship_callsign()

  return eid
}

spawn_character :: proc() -> EID {
  eid, _ := spawn()

  char, _ := add_component(&components.character, eid)
  char.name = make_random_full_name()

  return eid
}
