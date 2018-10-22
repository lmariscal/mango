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

proc createMesh*(vertices: var seq[float32], indices: var seq[uint32]): Mesh =
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

  glBufferData(GL_ARRAY_BUFFER, int32(float32.sizeof * vertices.len), vertices[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, int32(uint32.sizeof * indices.len), indices[0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, float32.sizeof * 5, cast[pointer](0))
  glVertexAttribPointer(1, 2, EGL_FLOAT, false, float32.sizeof * 5, cast[pointer](3 * float32.sizeof))

  result.len.vertices = vertices.len.int32
  result.len.indices = indices.len.int32

proc calcNormals*(mesh: Mesh): seq[Vec3[float32]] =
  nil

proc use*(mesh: Mesh) =
  glBindVertexArray(mesh.vao)
  glDrawElements(GL_TRIANGLES, mesh.len.indices, GL_UNSIGNED_INT, nil)

proc clean*(mesh: var Mesh) =
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)
  glDeleteVertexArrays(1, mesh.vao.addr)
