#+private
package game

import ecs "deps:ode_ecs"

EID :: ecs.entity_id
EntityIterator :: ecs.Iterator
none: EID

get_entity :: ecs.get_entity
get_component :: ecs.get_component
iterate_view :: ecs.iterator_init
iterate_next :: ecs.iterator_next
tag :: ecs.tag
untag :: ecs.untag

@(private = "file")
ECS_CAP :: 4096


// #region World
world: ecs.Database

world_load :: proc() {
  ecs.init(&world, ECS_CAP)
  init_components()
  init_tags()
  init_views()
  none, _ = ecs.create_entity(&world)
}

spawn :: proc() -> (EID, bool) {
  id, err := ecs.create_entity(&world)
  return id, err == nil
}

despawn :: proc(eid: EID) {
  components_unload(eid)
  ecs.destroy_entity(&world, eid)
}
// #endregion


// #region Components
components: struct {
  physical:  ecs.Table(Physical),
  station:   ecs.Table(Station),
  ship:      ecs.Table(Ship),
  character: ecs.Table(Character),
}

@(private = "file")
init_components :: proc() {
  ecs.table_init(&components.physical, &world, ECS_CAP)
  ecs.table_init(&components.station, &world, ECS_CAP)
  ecs.table_init(&components.ship, &world, ECS_CAP)
  ecs.table_init(&components.character, &world, ECS_CAP)
}

add_component :: proc(component: ^ecs.Table($T), eid: EID) -> (^T, bool) {
  c, err := ecs.add_component(component, eid)
  // when T == Body do init_body(c, eid)
  // when T == Renderer do init_renderer(c)
  return c, err == nil
}
// #endregion


// #region Tags
tags: struct {
  player: ecs.Tag_Table,
}

@(private = "file")
init_tags :: proc() {
  ecs.tag_table__init(&tags.player, &world, 64)
}
// #endregion


// #region Views
views: struct {
  player_characters: ecs.View,
}

init_views :: proc() {
  ecs.view_init(&views.player_characters, &world, {&tags.player, &components.character})
}
// #endregion
