# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm
import ../graphics

type
  Mesh* = object
    vertices*: seq[float32]
    indices*: seq[uint32]
    vao*: VertexDecl
    vbo*: VertexBuffer
    idx*: IndexBuffer

proc newMesh*(vertices: var seq[float32], uvs: var seq[float32], normals: var seq[float32], indices: var seq[uint32]): Mesh =
  result.vertices = vertices
  result.indices = indices
  result.vao = newVertexDecl()
  result.vbo = newVertexBuffer()
  result.idx = newIndexBuffer()

  result.vao.use()

  if indices.len == 0:
    for i in 0 ..< (vertices.len / 3).int32:
      result.indices.add(i.uint32)

  result.vbo.use()
  result.vbo.data(fSize(vertices.len + uvs.len + normals.len), vertices, duStaticDraw)
  result.vbo.subData(fSize(vertices.len), fSize(uvs.len), uvs)
  result.vbo.subData(fSize(vertices.len + uvs.len), fSize(normals.len), normals)

  result.idx.use()
  result.idx.data(iSize(result.indices.len), result.indices, duStaticDraw)

  result.vao.add(vaFloat3, fSize(3), 0)
  result.vao.add(vaFloat2, fSize(2), fSize(vertices.len))
  result.vao.add(vaFloat3, fSize(3), fSize(vertices.len + uvs.len))

proc use*(mesh: Mesh) =
  mesh.vao.drawElements(dmTriangles, mesh.indices.len, dtUInt, 0)

proc clean*(mesh: var Mesh) =
  mesh.vbo.clean()
  mesh.idx.clean()
  mesh.vao.clean()
