# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm
import ../graphics

type
  Mesh* = object of RootObj
    vertices*: seq[f32]
    indices*: seq[u32]
    vao*: VertexDecl
    vbo*: VertexBuffer
    idx*: IndexBuffer
  LineMesh* = object of Mesh

proc newLineMesh*(vertices: var seq[f32], indices: var seq[u32]): LineMesh =
  result.vertices = vertices
  result.indices = indices
  result.vao = newVertexDecl()
  result.vbo = newVertexBuffer()
  result.idx = newIndexBuffer()

  result.vao.use()

  if indices.len == 0:
    for i in 0 ..< (vertices.len / 3).i32:
      result.indices.add(i.u32)

  result.vbo.use()
  result.vbo.data(fSize(vertices.len), vertices, duStaticDraw)

  result.idx.use()
  result.idx.data(iSize(result.indices.len), result.indices, duStaticDraw)

  result.vao.add(vaFloat3, fSize(3), 0)

proc newMesh*(vertices: var seq[f32], indices: var seq[u32]): Mesh =
  result.vertices = vertices
  result.indices = indices
  result.vao = newVertexDecl()
  result.vbo = newVertexBuffer()
  result.idx = newIndexBuffer()

  result.vao.use()

  if indices.len == 0:
    for i in 0 ..< (vertices.len / 3).i32:
      result.indices.add(i.u32)

  result.vbo.use()
  result.vbo.data(fSize(vertices.len), vertices, duStaticDraw)

  result.idx.use()
  result.idx.data(iSize(result.indices.len), result.indices, duStaticDraw)

  result.vao.add(vaFloat3, fSize(3), 0)

proc newMesh*(vertices: var seq[f32], uvs: var seq[f32], normals: var seq[f32], indices: var seq[u32]): Mesh =
  result.vertices = vertices
  result.indices = indices
  result.vao = newVertexDecl()
  result.vbo = newVertexBuffer()
  result.idx = newIndexBuffer()

  result.vao.use()

  if indices.len == 0:
    for i in 0 ..< (vertices.len / 3).i32:
      result.indices.add(i.u32)

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

proc use*(mesh: LineMesh) =
  mesh.vao.drawElements(dmLines, mesh.indices.len, dtUInt, 0)

proc use*(mesh: Mesh, offset: i32, size: i32) =
  mesh.vao.drawElements(dmTriangles, size, dtUInt, offset)

proc use*(mesh: LineMesh, offset: i32, size: i32) =
  mesh.vao.drawElements(dmLines, size, dtUInt, offset)

proc clean*(mesh: var Mesh) =
  mesh.vbo.clean()
  mesh.idx.clean()
  mesh.vao.clean()
