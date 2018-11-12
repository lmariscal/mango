# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/opengl
import glm
import ../graphics
import ../core/logger

var
  currentVertexBuffer: uint32
  currentIndexBuffer: uint32
  currentVertexDecl: uint32
  currentTexture2D: uint32

proc mgInit*(): bool =
  glInit()

proc mgDepthTest*(toggle: bool): void =
  if toggle:
    glEnable(GL_DEPTH_TEST)
  else:
    glDisable(GL_DEPTH_TEST)

proc mgScissorTest*(toggle: bool): void =
  if toggle:
    glEnable(GL_SCISSOR_TEST)
  else:
    glDisable(GL_SCISSOR_TEST)

proc mgSetViewRect*(x1: int32, y1: int32, x2: int32, y2: int32): void =
  glViewPort(x1, y1, x2, y2)

proc mgSetScissor*(x1: int32, y1: int32, x2: int32, y2: int32): void =
  glScissor(x1, y1, x2, y2)

proc mgClearColor*(r: float32, g: float32, b: float32, a: float32): void =
  glClearColor(r, g, b, a)

proc mgClearBuffers*(): void =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc newVertexDecl*(): VertexDecl =
  result.attribs = 0
  glGenVertexArrays(1, result.id.addr)

proc newIndexBuffer*(): IndexBuffer =
  glGenBuffers(1, result.id.addr)

proc newVertexBuffer*(): VertexBuffer =
  glGenBuffers(1, result.id.addr)

proc newTexture2D*(): Texture2D =
  glGenTextures(1, result.id.addr)
  glBindTexture(GL_TEXTURE_2D, result.id)

  # @TODO: Make Tex Parameteri into its own option
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.int32)

proc getTextureFormat(format: TextureFormat): uint32 =
  case format
    of tfRed:
      result = GL_RED
    of tfRG:
      result = GL_RG
    of tfRGB:
      result = GL_RGB
    of tfBGR:
      result = GL_BGR
    of tfRGBA:
      result = GL_RGBA
    of tfBGRA:
      result = GL_BGRA
    of tfRedInteger:
      result = GL_RED_INTEGER
    of tfRGInteger:
      result = GL_RG_INTEGER
    of tfRGBInteger:
      result = GL_RGB_INTEGER
    of tfBGRInteger:
      result = GL_BGR_INTEGER
    of tfRGBAInteger:
      result = GL_RGBA_INTEGER
    of tfBGRAInteger:
      result = GL_BGRA_INTEGER
    of tfStencilIndex:
      result = GL_BGRA_INTEGER
    of tfDepthComponent:
      result = GL_DEPTH_COMPONENT
    of tfDepthStencil:
      result = GL_DEPTH_STENCIL

proc use*(tex: Texture2D, active: uint32 = 0): void =
  if tex.id == currentTexture2D: return
  glActiveTexture(GL_TEXTURE0 + active)
  glBindTexture(GL_TEXTURE_2D, tex.id)

proc data*(tex: Texture2D, internal_format: TextureFormat, format: TextureFormat, `type`: DataType, width: int32, height: int32, data: ptr cuchar): void =
  if tex.id != currentTexture2D: tex.use()
  var type_gl = 0'u32
  case `type`:
    of dtUByte:
      type_gl = GL_UNSIGNED_BYTE
    of dtUShort:
      type_gl = GL_UNSIGNED_SHORT
    of dtUInt:
      type_gl = GL_UNSIGNED_INT
    of tdByte:
      type_gl = EGL_BYTE
    of tdShort:
      type_gl = EGL_SHORT
    of tdInt:
      type_gl = EGL_INT
    of tdFloat:
      type_gl = EGL_FLOAT
  glTexImage2D(GL_TEXTURE_2D, 0, internal_format.getTextureFormat(), width, height, 0, format.getTextureFormat(), type_gl, data)

proc genMipMap*(tex: Texture2D): void =
  if tex.id != currentTexture2D: tex.use()
  glGenerateMipmap(GL_TEXTURE_2D)

proc clean*(tex: Texture2D): void =
  glDeleteTextures(1, tex.id.unsafeAddr)

proc clean*(vao: VertexDecl): void =
  glDeleteVertexArrays(1, vao.id.unsafeAddr)

proc clean*(vbo: VertexBuffer): void =
  glDeleteBuffers(1, vbo.id.unsafeAddr)

proc clean*(idx: IndexBuffer): void =
  glDeleteBuffers(1, idx.id.unsafeAddr)

proc use*(vao: VertexDecl): void =
  if currentVertexDecl == vao.id: return
  currentVertexDecl = vao.id
  glBindVertexArray(vao.id)

proc use*(vbo: VertexBuffer): void =
  if currentVertexBuffer == vbo.id: return
  currentVertexBuffer = vbo.id
  glBindBuffer(GL_ARRAY_BUFFER, vbo.id)

proc use*(idx: IndexBuffer): void =
  if currentIndexBuffer == idx.id: return
  currentIndexBuffer = idx.id
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, idx.id)

proc getUsage(usage: DataUsage): uint32 =
  if usage == duStreamDraw:
    result = GL_STREAM_DRAW
  elif usage == duStreamRead:
    result = GL_STREAM_READ
  elif usage == duStreamCopy:
    result = GL_STREAM_COPY
  elif usage == duStaticDraw:
    result = GL_STATIC_DRAW
  elif usage == duStaticRead:
    result = GL_STATIC_READ
  elif usage == duStaticCopy:
    result = GL_STATIC_COPY
  elif usage == duDynamicDraw:
    result = GL_DYNAMIC_DRAW
  elif usage == duDynamicRead:
    result = GL_DYNAMIC_READ
  elif usage == duDynamicCopy:
    result = GL_DYNAMIC_COPY

proc data*(vbo: VertexBuffer, size: int32, data: pointer, usage: DataUsage): void =
  if currentVertexBuffer != vbo.id: vbo.use()
  glBufferData(GL_ARRAY_BUFFER, size, data, usage.getUsage())

proc data*[N, T](vbo: VertexBuffer, size: int32, data: var array[N, T], usage: DataUsage): void =
  vbo.data(size, data[0].addr, usage)

proc data*[T](vbo: VertexBuffer, size: int32, data: var seq[T], usage: DataUsage): void =
  vbo.data(size, data[0].addr, usage)

proc subData*(vbo: VertexBuffer, offset: int32, size: int32, data: pointer): void =
  if currentVertexBuffer != vbo.id: vbo.use()
  glBufferSubData(GL_ARRAY_BUFFER, offset, size, data)

proc subData*[N, T](vbo: VertexBuffer, offset: int32, size: int32, data: var array[N, T]): void =
  vbo.subData(offset, size, data[0].addr)

proc subData*[T](vbo: VertexBuffer, offset: int32, size: int32, data: var seq[T]): void =
  vbo.subData(offset, size, data[0].addr)

proc data*(idx: IndexBuffer, size: int32, data: pointer, usage: DataUsage): void =
  if currentIndexBuffer != idx.id: idx.use()
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, usage.getUsage())

proc data*[N, T](idx: IndexBuffer, size: int32, data: var array[N, T], usage: DataUsage): void =
  idx.data(size, data[0].addr, usage)

proc data*[T](idx: IndexBuffer, size: int32, data: var seq[T], usage: DataUsage): void =
  idx.data(size, data[0].addr, usage)

proc subData*(idx: IndexBuffer, offset: int32, size: int32, data: pointer): void =
  if currentIndexBuffer != idx.id: idx.use()
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data)

proc subData*[N, T](idx: IndexBuffer, offset: int32, size: int32, data: var array[N, T]): void =
  idx.subData(offset, size, data[0].addr)

proc subData*[T](idx: IndexBuffer, offset: int32, size: int32, data: var seq[T]): void =
  idx.subData(offset, size, data[0].addr)

proc drawElements*(vao: VertexDecl, mode: DrawMode, count: int32, `type`: DataType, offset: pointer): void =
  var draw_mode: uint32 = 0
  var draw_type: uint32 = 0
  case mode:
    of dmPoints:
      draw_mode = GL_POINTS
    of dmLineStrip:
      draw_mode = GL_LINE_STRIP
    of dmLineLoop:
      draw_mode = GL_LINE_LOOP
    of dmLines:
      draw_mode = GL_LINES
    of dmLineStripAdjacency:
      draw_mode = GL_LINE_STRIP_ADJACENCY
    of dmLinesAdjacency:
      draw_mode = GL_LINES_ADJACENCY
    of dmTriangleStrip:
      draw_mode = GL_TRIANGLE_STRIP
    of dmTriangleFan:
      draw_mode = GL_TRIANGLE_FAN
    of dmTriangles:
      draw_mode = GL_TRIANGLES
    of dmTriangleStripAdjacency:
      draw_mode = GL_TRIANGLE_STRIP_ADJACENCY
    of dmTrianglesAdjacency:
      draw_mode = GL_TRIANGLES_ADJACENCY
  case `type`:
    of dtUByte:
      draw_type = GL_UNSIGNED_BYTE
    of dtUShort:
      draw_type = GL_UNSIGNED_SHORT
    of dtUInt:
      draw_type = GL_UNSIGNED_INT
    else:
      error("Graphics", "unvalid type for drawElements")

  glDrawElements(draw_mode, count, draw_type, offset)

proc drawElements*(vao: VertexDecl, mode: DrawMode, count: int32, `type`: DataType, offset: int32): void =
  vao.use()
  vao.drawElements(mode, count, `type`, cast[pointer](offset))

# @TODO: In the future add ability to set attrib pos
proc add*(vao: var VertexDecl, `type`: VertexAttrib, stride: int32, offset: int32): void =
  var data_size: int32 = 0
  var data_type: uint32 = 0
  case `type`
    of vaFloat1:
      data_size = 1
      data_type = EGL_FLOAT
    of vaFloat2:
      data_size = 2
      data_type = EGL_FLOAT
    of vaFloat3:
      data_size = 3
      data_type = EGL_FLOAT
    of vaFloat4:
      data_size = 4
      data_type = EGL_FLOAT
    of vaByte:
      data_size = 1
      data_type = EGL_BYTE
    of vaUByte:
      data_size = 1
      data_type = GL_UNSIGNED_BYTE
    of vaShort:
      data_size = 1
      data_type = EGL_SHORT
    of vaUShort:
      data_size = 1
      data_type = GL_UNSIGNED_SHORT
    of vaInt1:
      data_size = 1
      data_type = EGL_INT
    of vaInt2:
      data_size = 2
      data_type = EGL_INT
    of vaInt3:
      data_size = 3
      data_type = EGL_INT
    of vaInt4:
      data_size = 4
      data_type = EGL_INT
    of vaUInt1:
      data_size = 1
      data_type = GL_UNSIGNED_INT
    of vaUInt2:
      data_size = 2
      data_type = GL_UNSIGNED_INT
    of vaUInt3:
      data_size = 3
      data_type = GL_UNSIGNED_INT
    of vaUInt4:
      data_size = 4
      data_type = GL_UNSIGNED_INT
    of vaDouble1:
      data_size = 1
      data_type = EGL_DOUBLE
    of vaDouble2:
      data_size = 2
      data_type = EGL_DOUBLE
    of vaDouble3:
      data_size = 3
      data_type = EGL_DOUBLE
    of vaDouble4:
      data_size = 4
      data_type = EGL_DOUBLE

  glEnableVertexAttribArray(vao.attribs)
  if `type`.ord <= vaFloat4.ord:
    glVertexAttribPointer(vao.attribs, data_size, data_type, false, stride, cast[pointer](offset))
  elif `type`.ord <= vaUInt4.ord:
    glVertexAttribIPointer(vao.attribs, data_size, data_type, stride, cast[pointer](offset))
  else:
    glVertexAttribLPointer(vao.attribs, data_size, data_type, stride, cast[pointer](offset))
  vao.attribs = vao.attribs + 1'u32
