# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import ../graphics/[mesh, shader], ../core/utils
import glm

type Space* = object
  mesh*: LineMesh
  shader*: Shader
  uModel*: int32
  uView*: int32
  uProjection*: int32

proc newSpace*(): Space =
  var
    vertices: seq[float32] = @[
      0.5f,  0.5f, 0.0f,
      0.5f, -0.5f, 0.0f,
     -0.5f, -0.5f, 0.0f,
     -0.5f,  0.5f, 0.0f,
    ]
    indices: seq[uint32] = @[
      0'u32, 1, 1, 2, 2, 3, 3, 0
    ]

  const data = readShader("res/shaders/simpleColor.glsl")

  result.shader = newShader(data)
  result.mesh = newLineMesh(vertices, indices)
  result.uModel = result.shader.getLocation("uModel")
  result.uView = result.shader.getLocation("uView")
  result.uProjection = result.shader.getLocation("uProjection")

proc use*(space: var Space, proj: var Mat4f): void =
  var trans = mat4(1.0f).translate(0.0f, 0.0f, -5.0f)
  var view = mat4(1.0f)
  space.shader.setMat(space.uModel, trans)
  space.shader.setMat(space.uView, view)
  space.shader.setMat(space.uProjection, proj)

  space.mesh.use()

proc clean*(space: var Space): void =
  space.shader.clean()
  space.mesh.clean()
