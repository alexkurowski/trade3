package render

import rl "vendor:raylib"

Model :: struct {
  kind:     ModelKind,
  position: Vec3,
  rotation: f32,
  scale:    Vec3,
  color:    rl.Color,
}

ModelKind :: enum {
  None,
  Test,
  WallSmall00,
}

@(private = "file")
model_queue: Pool(Model, 1024)

models_begin :: proc() {
  clear_pool(&model_queue)
}

models_end :: proc() {
  rl.BeginShaderMode(shaders.lighting)
  defer rl.EndShaderMode()

  for model in every(&model_queue) {
    m := get_mesh(model.kind)

    scale := rl.MatrixScale(model.scale.x, model.scale.y, model.scale.z)
    rotate := rl.MatrixRotate(Vec3{0, 1, 0}, -model.rotation)
    translate := rl.MatrixTranslate(model.position.x, model.position.y, model.position.z)
    transform := translate * rotate * scale * m.transform

    for i := i32(0); i < m.meshCount; i += 1 {
      m.materials[m.meshMaterial[i]].maps[rl.MaterialMapIndex.ALBEDO].color = model.color
      rl.DrawMesh(m.meshes[i], m.materials[m.meshMaterial[i]], transform)
    }
  }
}

model :: proc(
  kind: ModelKind,
  position: Vec3 = Vec3(0),
  rotation: f32,
  scale: Vec3 = Vec3(1),
  color: rl.Color = rl.WHITE,
) {
  push(
    &model_queue,
    Model{kind = kind, position = position, rotation = rotation, scale = scale, color = color},
  )
}

@(private = "file")
get_mesh :: proc(kind: ModelKind) -> rl.Model {
  switch kind {
  case .None:
  // NOP
  case .Test:
    return models.test
  case .WallSmall00:
    return models.wall_small_00
  }
  return models.test
}

