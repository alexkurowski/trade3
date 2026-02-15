#+private file
package game

import "core:math"
import "core:slice"
import "deps:box"

@(private)
generate_new_world :: proc() {
  // Generate factions
  for i := 0; i < FACTION_COUNT; i += 1 {
    box.append(&world.factions, Faction{name = make_faction_name()})
  }

  // Generate companies
  for i := 0; i < COMPANY_COUNT; i += 1 {
    box.append(&world.companies, Company{name = make_random_name()})
  }
  g.player_company_id = world.companies.items[0].id

  // Generate systems
  system_ids: [SYSTEM_COUNT]ID
  for i := 0; i < SYSTEM_COUNT; i += 1 {
    system_ids[i] = box.append(
      &world.locations,
      Location {
        kind = .System,
        name = make_random_name(),
        position = to_vec3(rand_offset(10, 50), randf(-5, 5)),
        parent_id = none,
      },
    )
  }

  // Generate routes between systems
  {
    connect_systems :: proc(a, b: ^Location) -> bool {
      if box.is_full(&a.connection_ids) || box.is_full(&b.connection_ids) {
        // Too many connections
        return false
      }

      // Add a->b connection
      box.append(&a.connection_ids, b.id)

      // Add b->a connection
      for id in box.every(&b.connection_ids) {
        if id == a.id {
          // Already exists
          return true
        }
      }

      box.append(&b.connection_ids, a.id)

      return true
    }

    OtherSystem :: struct {
      id:       ID,
      distance: f32,
    }
    other_systems: box.Pool(OtherSystem, SYSTEM_COUNT)
    other_angles: box.Pool(f32, 4)
    for i := 0; i < SYSTEM_COUNT; i += 1 {
      system := box.get(&world.locations, system_ids[i])
      box.clear(&other_systems)

      for j := 0; j < SYSTEM_COUNT; j += 1 {
        if i == j do continue
        other_system := box.get(&world.locations, system_ids[j])
        d := distance(system.position, other_system.position)
        box.append(&other_systems, OtherSystem{id = system_ids[j], distance = d})
      }

      // Sort other systems by distance
      slice.sort_by_cmp(
        box.every(&other_systems),
        proc(a: OtherSystem, b: OtherSystem) -> slice.Ordering {
          if a.distance < b.distance {
            return .Less
          } else if a.distance > b.distance {
            return .Greater
          } else {
            return .Equal
          }
        },
      )

      // Pick up to 3 closest sectors with angle separation and create connection
      box.clear(&other_angles)
      outer_loop: for j := i32(0); j < 4; j += 1 {
        if other_angles.count >= 4 do break
        if other_systems.count <= j do break

        other_system := box.get(&world.locations, other_systems.items[j].id)

        // Skip if angle too close to existing connection
        angle := angle_between(system.position, other_system.position)
        min_angle :: PI / 4 // 45 degrees
        for other_angle in box.every(&other_angles) {
          angle_diff := abs(angle - other_angle)
          if angle_diff < min_angle || angle_diff > TAU - min_angle {
            continue outer_loop
          }
        }

        if connect_systems(system, other_system) {
          box.append(&other_angles, angle)
        }
      }
    }
  }

  // Generate planets
  for i := 0; i < SYSTEM_COUNT; i += 1 {
    system_id := system_ids[i]
    parent_position := box.get(&world.locations, system_id).position
    planet_count := randu_bell(0, 6, 3)

    planet_distance := f32(10)
    for j := u16(0); j < planet_count; j += 1 {
      planet_position := parent_position + at_angle(rand_angle()) * planet_distance
      planet_size := randf_bell(5, 10, 2)
      planet_id := box.append(
        &world.locations,
        Location {
          kind = .Planet,
          name = make_random_name(),
          position = planet_position,
          size = planet_size,
          parent_id = system_id,
        },
      )
      planet_distance += randf(10, 20)

      city_count := randu_bell(0, 10, 2)
      for k := u16(0); k < city_count; k += 1 {
        lat := randf(0, 360)
        lon := randf(-75, 75)
        city_position: Vec3
        city_position.x = math.cos(lon * DEG_TO_RAD) * math.sin(lat * DEG_TO_RAD)
        city_position.y = math.sin(lon * DEG_TO_RAD)
        city_position.z = math.cos(lon * DEG_TO_RAD) * math.cos(lat * DEG_TO_RAD)
        city_position *= planet_size
        city_position += planet_position

        box.append(
          &world.locations,
          Location {
            kind = .City,
            name = make_random_name(),
            position = city_position,
            parent_id = planet_id,
          },
        )
      }
    }
  }
}
