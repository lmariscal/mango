import nimgl/opengl
import glm
import ../graphics
import ../core/logger

var
  currentVertexBuffer: u32
  currentIndexBuffer: u32
  currentVertexDecl: u32
  currentTexture2D: u32
  currentShaderProgram: u32

converter toU32(e: GLenum): u32 =
  e.u32

converter toGLenum(u: u32): GLenum =
  u.GLenum

converter toString(chars: seq[cchar]): string =
  result = ""
  for c in chars:
    if c == '\0': continue
    result.add(c)

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

proc mgCullTest*(toggle: bool): void =
  if toggle:
    glEnable(GL_CULL_FACE)
    glCullFace(GL_BACK)
    glFrontFace(GL_CCW)
  else:
    glDisable(GL_CULL_FACE)

proc mgSetViewRect*(x1: i32, y1: i32, x2: i32, y2: i32): void =
  glViewPort(x1, y1, x2, y2)

proc mgSetScissor*(x1: i32, y1: i32, x2: i32, y2: i32): void =
  glScissor(x1, y1, x2, y2)

proc mgClearColor*(r: f32, g: f32, b: f32, a: f32): void =
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
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.i32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.i32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.i32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.i32)

proc getTextureFormat(format: TextureFormat): u32 =
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

proc use*(tex: Texture2D, active: u32 = 0): void =
  if tex.id == currentTexture2D: return
  glActiveTexture(GL_TEXTURE0 + active)
  glBindTexture(GL_TEXTURE_2D, tex.id)

proc data*(tex: Texture2D, internal_format: TextureFormat, format: TextureFormat, `type`: DataType, width: i32, height: i32, data: ptr u8): void =
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

proc getUsage(usage: DataUsage): u32 =
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

proc data*(vbo: VertexBuffer, size: i32, data: pointer, usage: DataUsage): void =
  if currentVertexBuffer != vbo.id: vbo.use()
  glBufferData(GL_ARRAY_BUFFER, size, data, usage.getUsage())

proc data*[N, T](vbo: VertexBuffer, size: i32, data: var array[N, T], usage: DataUsage): void =
  vbo.data(size, data[0].addr, usage)

proc data*[T](vbo: VertexBuffer, size: i32, data: var seq[T], usage: DataUsage): void =
  vbo.data(size, data[0].addr, usage)

proc subData*(vbo: VertexBuffer, offset: i32, size: i32, data: pointer): void =
  if currentVertexBuffer != vbo.id: vbo.use()
  glBufferSubData(GL_ARRAY_BUFFER, offset, size, data)

proc subData*[N, T](vbo: VertexBuffer, offset: i32, size: i32, data: var array[N, T]): void =
  vbo.subData(offset, size, data[0].addr)

proc subData*[T](vbo: VertexBuffer, offset: i32, size: i32, data: var seq[T]): void =
  vbo.subData(offset, size, data[0].addr)

proc data*(idx: IndexBuffer, size: i32, data: pointer, usage: DataUsage): void =
  if currentIndexBuffer != idx.id: idx.use()
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, usage.getUsage())

proc data*[N, T](idx: IndexBuffer, size: i32, data: var array[N, T], usage: DataUsage): void =
  idx.data(size, data[0].addr, usage)

proc data*[T](idx: IndexBuffer, size: i32, data: var seq[T], usage: DataUsage): void =
  idx.data(size, data[0].addr, usage)

proc subData*(idx: IndexBuffer, offset: i32, size: i32, data: pointer): void =
  if currentIndexBuffer != idx.id: idx.use()
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data)

proc subData*[N, T](idx: IndexBuffer, offset: i32, size: i32, data: var array[N, T]): void =
  idx.subData(offset, size, data[0].addr)

proc subData*[T](idx: IndexBuffer, offset: i32, size: i32, data: var seq[T]): void =
  idx.subData(offset, size, data[0].addr)

proc drawElements*(vao: VertexDecl, mode: DrawMode, count: i32, `type`: DataType, offset: pointer): void =
  var draw_mode: u32 = 0
  var draw_type: u32 = 0
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

proc drawElements*(vao: VertexDecl, mode: DrawMode, count: i32, `type`: DataType, offset: i32): void =
  vao.use()
  vao.drawElements(mode, count, `type`, cast[pointer](offset))

# @TODO: In the future add ability to set attrib pos
proc add*(vao: var VertexDecl, `type`: VertexAttrib, stride: i32, offset: i32): void =
  var data_size: i32 = 0
  var data_type: u32 = 0
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

proc statusShader(shader: u32, `type`: string, path: string) =
  var status: i32
  shader.glGetShaderiv(GL_COMPILE_STATUS, status.addr)
  if status != GL_TRUE.ord:
    var length: i32
    var message = newSeq[cchar](1024)
    shader.glGetShaderInfoLog(1024, length.addr, message[0].addr)
    error("ShaderManager", "failed to compile " & `type` & " shader \"" & path & "\":")
    error("ShaderManager", message.toString())

proc statusProgram(program: u32) =
  var status: i32
  program.glGetProgramiv(GL_LINK_STATUS, status.addr)
  if status != GL_TRUE.ord:
    var length: i32
    var message = newSeq[cchar](1024)
    program.glGetProgramInfoLog(1024, length.addr, message[0].addr)
    error("ShaderManager", "failed to link shader program {program}".fmt)
    error("ShaderManager", message.toString())

proc newShaderProgram*(vertexSource: cstring, fragmentSource: cstring, vertexPath: string, fragmentPath: string): ShaderProgram =
  result.vertex.id = glCreateShader(GL_VERTEX_SHADER)
  result.vertex.id.glShaderSource(1, vertexSource.unsafeAddr, nil)
  result.vertex.id.glCompileShader()
  result.vertex.id.statusShader("vertex", vertexPath)

  result.fragment.id = glCreateShader(GL_FRAGMENT_SHADER)
  result.fragment.id.glShaderSource(1, fragmentSource.unsafeAddr, nil)
  result.fragment.id.glCompileShader()
  result.fragment.id.statusShader("fragment", fragmentPath)

  result.id = glCreateProgram()
  result.id.glAttachShader(result.vertex.id)
  result.id.glAttachShader(result.fragment.id)
  result.id.glLinkProgram()
  result.id.statusProgram()

proc use*(program: ShaderProgram): void =
  currentShaderProgram = program.id
  program.id.glUseProgram()

proc clean*(program: ShaderProgram): void =
  program.vertex.id.glDeleteShader()
  program.fragment.id.glDeleteShader()
  program.id.glDeleteProgram()

proc uniformLocation*(program: ShaderProgram, name: string): i32 =
  if currentShaderProgram != program.id: program.use()
  result = program.id.glGetUniformLocation(name.cstring)

proc attribLocation*(program: ShaderProgram, name: string): i32 =
  if currentShaderProgram != program.id: program.use()
  result = program.id.glGetAttribLocation(name.cstring)

proc uniformMatrix*(program: ShaderProgram, location: i32, mat: var Mat4f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniformMatrix4fv(location, 1, false, mat.caddr)

proc uniformMatrix*(program: ShaderProgram, location: i32, mat: var Mat3f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniformMatrix3fv(location, 1, false, mat.caddr)

proc uniformMatrix*(program: ShaderProgram, location: i32, mat: var Mat2f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniformMatrix2fv(location, 1, false, mat.caddr)


proc uniformVector*(program: ShaderProgram, location: i32, vec: var Vec4f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniform4fv(location, 1, vec.caddr)

proc uniformVector*(program: ShaderProgram, location: i32, vec: var Vec3f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniform3fv(location, 1, vec.caddr)

proc uniformVector*(program: ShaderProgram, location: i32, vec: var Vec2f): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniform2fv(location, 1, vec.caddr)

proc uniformInt*(program: ShaderProgram, location: i32, val: i32): void =
  if location < 0: return
  if currentShaderProgram != program.id: program.use()
  glUniform1i(location, val)

proc mgLineWidth*(width: f32): void =
  glLineWidth(width)

proc mgWireframe*(toggle: bool): void =
  glPolygonMode(GL_FRONT_AND_BACK, if toggle: GL_LINE else: GL_FILL)
