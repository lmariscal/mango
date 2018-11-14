# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import ../graphics/[mesh, shader]
import ../core/[utils, ioman, window]
import ../graphics
import nimgl/opengl
import glm

type Space* = object
  mesh*: LineMesh
  shader*: Shader
  uColor*: i32
  uModel*: i32
  uView*: i32
  uProjection*: i32

proc newSpace*(width: u32, height: u32): Space =
  var
    vertices: seq[f32] = @[]
    indices: seq[u32] = @[]

  for i in 0..width:
    vertices.add((-width.f32 / 2.0f) + i.f32)
    vertices.add(0.0f)
    vertices.add(-height.f32 / 2.0f)

    vertices.add((-width.f32 / 2.0f) + i.f32)
    vertices.add(0.0f)
    vertices.add(height.f32 / 2.0f)

  for i in 0..width:
    if (i * 2) == width or ((i * 2) + 1) == width + 1: continue
    indices.add(i.u32 * 2)
    indices.add((i.u32 * 2) + 1)

  for i in 0..height:
    vertices.add(-width.f32 / 2.0f)
    vertices.add(0.0f)
    vertices.add((-height.f32 / 2.0f) + i.f32)

    vertices.add(width.f32 / 2.0f)
    vertices.add(0.0f)
    vertices.add((-height.f32 / 2.0f) + i.f32)

  for i in 0..height + 1:
    if (i * 2) == height + 2 or ((i * 2) + 1) == height + 3: continue
    indices.add((i.u32 * 2) + (width * 2))
    indices.add((i.u32 * 2) + (width * 2) + 1)

  indices.add([width, width + 1'u32, (width * 2) + height + 2'u32, (width * 2) + height + 3'u32])

  const data = readShader("res/shaders/grid.glsl")

  result.shader = newShader(data)
  result.mesh = newLineMesh(vertices, indices)
  result.uColor = result.shader.getLocation("uColor")
  result.uModel = result.shader.getLocation("uModel")
  result.uView = result.shader.getLocation("uView")
  result.uProjection = result.shader.getLocation("uProjection")

var pos = vec3(0.0f, -20.0f, -40.0f)
var velocity = 10.0f
proc use*(space: var Space, proj: var Mat4f): void =
  var trans = mat4(1.0f)
  var view = mat4(1.0f).rotate(radians(15.0f), vec3(1.0f, 0.0f, 0.0f)).translate(pos)
  var color = rgb(250f, 250f, 250f)
  space.shader.setMat(space.uModel, trans)
  space.shader.setMat(space.uView, view)
  space.shader.setMat(space.uProjection, proj)

  mgLineWidth(1.0f)
  space.shader.setVec(space.uColor, color)
  space.mesh.use(0, 66)
  mgLineWidth(2.0f) # Not all platforms support width, but there's color
  color = rgb(33f, 150f, 243f)
  space.shader.setVec(space.uColor, color)
  space.mesh.use(u32.sizeof() * 66, 2)
  color = rgb(244f, 67f, 54f)
  space.shader.setVec(space.uColor, color)
  space.mesh.use(u32.sizeof() * 68, 2)
  mgLineWidth(1.0f)

  var lineWidthRange: array[2, f32]
  glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, lineWidthRange[0].addr)

  let io = igGetIO()
  if keyQ.isPressed():
    pos.y += io.deltaTime * velocity
  elif keyE.isPressed():
    pos.y -= io.deltaTime * velocity

  if keyW.isPressed():
    pos.z += io.deltaTime * velocity
  elif keyS.isPressed():
    pos.z -= io.deltaTime * velocity

  if keyA.isPressed():
    pos.x += io.deltaTime * velocity
  elif keyD.isPressed():
    pos.x -= io.deltaTime * velocity

  igText("Pos: ")
  igSameLine()
  discard igDragFloat3("##pos", pos.x.addr)
  igText("fps: %f", io.framerate)

proc clean*(space: var Space): void =
  space.shader.clean()
  space.mesh.clean()
