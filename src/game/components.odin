#+private
package game

Physical :: struct {
  position: Vec3,
  velocity: Vec3,
}

Station :: struct {
  name: string,
}

Ship :: struct {
  callsign: string,
}

Character :: struct {
  name: string,
  at:   EID,
}

components_unload :: proc(eid: EID) {
  // Make sure we free all strings inside all components
  station := get_component(&components.station, eid)
  if station != nil do delete(station.name)

  ship := get_component(&components.ship, eid)
  if ship != nil do delete(ship.callsign)

  character := get_component(&components.character, eid)
  if character != nil do delete(character.name)
}
