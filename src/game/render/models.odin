package render

import "deps:box"
import rl "vendor:raylib"

Model :: struct {
  kind:     ModelKind,
  position: Vec3,
  rotation: rl.Quaternion,
  scale:    Vec3,
  color:    rl.Color,
}

ModelKind :: enum {
  Test,
}

@(private = "file")
model_queue: box.Pool(Model, 1024)

models_begin :: proc() {
  box.clear(&model_queue)
}

models_end :: proc() {
  rl.BeginShaderMode(shaders.lighting)
  defer rl.EndShaderMode()

  for model in box.every(&model_queue) {
    m := get_mesh(model.kind)

    scale := rl.MatrixScale(model.scale.x, model.scale.y, model.scale.z)
    rotate := rl.QuaternionToMatrix(model.rotation)
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
  rotation: rl.Quaternion = rl.Quaternion(1),
  scale: Vec3 = Vec3(1),
  color: rl.Color = rl.WHITE,
) {
  box.append(
    &model_queue,
    Model{kind = kind, position = position, rotation = rotation, scale = scale, color = color},
  )
}

@(private = "file")
get_mesh :: proc(kind: ModelKind) -> rl.Model {
  switch kind {
  case .Test:
    return models.test
  }
  return models.test
}

