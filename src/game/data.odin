#+private
package game

import box "deps:box"

Sector :: struct {
  id:       EID,
  name:     string,
  position: Vec3,
}

Station :: struct {
  id:        EID,
  name:      string,
  position:  Vec3,
  sector_id: EID,
}

Ship :: struct {
  id:        EID,
  name:      string,
  position:  Vec3,
  sector_id: EID,
}

Character :: struct {
  id:      EID,
  name:    string,
  ship_id: EID,
}


//


Kind :: enum u8 {
  None,
  Sector,
  Station,
  Ship,
  Character,
}

sectors: box.Array(Sector, EID, 32)
stations: box.Array(Station, EID, 128)
ships: box.Array(Ship, EID, 4096)
characters: box.Array(Character, EID, 4096)

player: struct {
  character_ids: box.Pool(EID, 32),

  // interaction
  select_kind:   Kind,
  select_id:     EID,
}
