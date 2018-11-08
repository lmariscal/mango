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

proc fSize(num: int): int32 =
  int32(float32.sizeof * num)

proc iSize(num: int): int32 =
  int32(int32.sizeof * num)

proc createMesh*(shader: uint32, vertices: var seq[float32], indices: var seq[uint32]): Mesh =
  result.vertices = vertices
  result.indices = indices
  glGenVertexArrays(1, result.vao.addr)
  glGenBuffers(1, result.vbo.addr)
  glGenBuffers(1, result.ebo.addr)

  glBindVertexArray(result.vao)

  if indices.len == 0:
    for i in 0 ..< vertices.len:
      indices.add(i.uint32)

  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glBufferData(GL_ARRAY_BUFFER, fSize(vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, result.ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, iSize(indices.len), indices[0].addr, GL_STATIC_DRAW)

  glUseProgram(shader)

  var iPos = shader.glGetAttribLocation("vPos").uint32
  var iUVs = shader.glGetAttribLocation("vUVs").uint32
  var iNormals = shader.glGetAttribLocation("vNormals").uint32

  glEnableVertexAttribArray(iPos)
  glEnableVertexAttribArray(iUVs)
  glEnableVertexAttribArray(iNormals)

  glVertexAttribPointer(iPos, 3, EGL_FLOAT, false, fSize(8), cast[pointer](0))
  glVertexAttribPointer(iUVs, 2, EGL_FLOAT, false, fSize(8), cast[pointer](fSize(3)))
  glVertexAttribPointer(iNormals, 3, EGL_FLOAT, false, fSize(8), cast[pointer](fSize(5)))

proc calcNormals*(mesh: Mesh): seq[float32] =
  nil

proc use*(mesh: Mesh) =
  glBindVertexArray(mesh.vao)
  glDrawElements(GL_TRIANGLES, mesh.indices.len.int32, GL_UNSIGNED_INT, cast[pointer](0))

proc clean*(mesh: var Mesh) =
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)
  glDeleteVertexArrays(1, mesh.vao.addr)
