# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/opengl
import glm

type
  Mesh* = object
    vertices*: seq[float32]
    indices*: seq[uint32]
    vao*: uint32
    ebo*: uint32
    vbo*: uint32
    len*: tuple[vertices: int32, indices: int32]

proc fSize(num: int): int32 =
  int32(float32.sizeof * num)

# @TODO: Make the inputs variable
proc createMesh*(vertices: var seq[float32], indices: var seq[uint32], uvs: var seq[float32], normals: var seq[float32]): Mesh =
  result.vertices = vertices
  result.indices = indices
  glGenBuffers(1, result.vbo.addr)
  glGenBuffers(1, result.ebo.addr)
  glGenVertexArrays(1, result.vao.addr)

  glBindVertexArray(result.vao)

  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, result.ebo)

  if indices.len == 0:
    for i in 0 ..< vertices.len:
      indices.add(i.uint32)

  glBufferData(GL_ARRAY_BUFFER, fSize(vertices.len + uvs.len), nil, GL_STATIC_DRAW)
  glBufferSubData(GL_ARRAY_BUFFER, fSize(vertices.len), int32(float32.sizeof * uvs.len), uvs[0].addr)

  #[
    acxzsq - 8
    2, 21, 2, 21, 2, 21, 2
    0, 4
    1, 3,
    2, 2,
  ]#

  glBufferData(GL_ELEMENT_ARRAY_BUFFER, int32(uint32.sizeof * indices.len), indices[0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  # glEnableVertexAttribArray(1)
  # glEnableVertexAttribArray(2)
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, float32.sizeof * 3, cast[pointer](0))
  # glVertexAttribPointer(1, 2, EGL_FLOAT, false, float32.sizeof * 5, cast[pointer](3 * float32.sizeof))
  # glVertexAttribPointer(2, 3, EGL_FLOAT, false, float32.sizeof * 8, cast[pointer](5 * float32.sizeof))

  result.len.vertices = vertices.len.int32
  result.len.indices = indices.len.int32

proc calcNormals*(mesh: Mesh): seq[float32] =
  nil

proc use*(mesh: Mesh) =
  glBindVertexArray(mesh.vao)
  glDrawElements(GL_TRIANGLES, mesh.len.indices, GL_UNSIGNED_INT, nil)

proc clean*(mesh: var Mesh) =
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)
  glDeleteVertexArrays(1, mesh.vao.addr)
