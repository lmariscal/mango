# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/opengl
import glm
import strutils
import logging

type
  Shader* = object
    id*: uint32
    vertex*: uint32
    fragment*: uint32

  ShaderSource* = object
    other*: cstring
    vertex*: cstring
    fragment*: cstring
    path*: string

converter toString(chars: seq[cchar]): string =
  result = ""
  for c in chars:
    if c == '\0': continue
    result.add(c)

proc readShader*(path: string): ShaderSource =
  var source: string
  result.path = path
  try:
    source = readFile(path)
  except:
    error("ShaderManager", "failed to open shader \"" & path & "\"")
    return

  var
    vertex = ""
    fragment = ""
    other = ""
    index = 0

  for line in source.splitLines:
    if line.startsWith("//"): continue
    elif line == "": continue

    if line[0] == '@':
      if line == "@vertex": index = 1
      elif line == "@fragment": index = 2
      elif line == "@other": index = 0
      elif line.startsWith("@include "):
        var name = line["@include ".len ..< line.len]
        if not name.endsWith(".glsl"): name.add(".glsl")

        let other_shader = readShader(path[0 .. path.rfind('/')] & name)
        if index == 0: other.add($other_shader.other)
        elif index == 1: vertex.add($other_shader.other)
        elif index == 2: fragment.add($other_shader.other)
      continue

    if index == 0: other.add(line & "\n")
    elif index == 1: vertex.add(line & "\n")
    elif index == 2: fragment.add(line & "\n")

  result.other = other
  result.vertex = vertex
  result.fragment = fragment

proc statusShader*(shader: uint32, `type`: string, path: string) =
  var status: int32
  shader.glGetShaderiv(GL_COMPILE_STATUS, status.addr)
  if status != GL_TRUE.ord:
    var length: int32
    var message = newSeq[cchar](1024)
    shader.glGetShaderInfoLog(1024, length.addr, message[0].addr)
    error("ShaderManager", "failed to compile " & `type` & " shader \"" & path & "\":")
    error("ShaderManager", message.toString())

proc newShader*(source: ShaderSource): Shader =
  result.vertex = glCreateShader(GL_VERTEX_SHADER)
  result.vertex.glShaderSource(1, source.vertex.unsafeAddr(), nil)
  result.vertex.glCompileShader()
  result.vertex.statusShader("vertex", source.path)

  result.fragment = glCreateShader(GL_FRAGMENT_SHADER)
  result.fragment.glShaderSource(1, source.fragment.unsafeAddr(), nil)
  result.fragment.glCompileShader()
  result.fragment.statusShader("fragment", source.path)

  result.id = glCreateProgram()
  result.id.glAttachShader(result.vertex)
  result.id.glAttachShader(result.fragment)
  result.id.glLinkProgram()

  var status: int32
  result.id.glGetProgramiv(GL_LINK_STATUS, status.addr)
  if status != GL_TRUE.ord:
    var length: int32
    var message = newSeq[cchar](1024)
    result.id.glGetProgramInfoLog(1024, length.addr, message[0].addr)
    error("ShaderManager", "failed to link shader program \"{source.path}\"".fmt)
    error("ShaderManager", message.toString())

  mlog("ShaderManager", "loading {source.path} shader".fmt)

proc newShader*(file: string): Shader =
  newShader(readShader(file))

proc use*(shader: Shader) =
  shader.id.glUseProgram()

# @TODO: Make a cache for this
proc getLocation*(shader: Shader, name: string): int32 =
  shader.use()
  result = shader.id.glGetUniformLocation(name.cstring)
  if result == -1:
    error("ShaderManager", "uniform " & name & " doesn't exist")

# @TODO: Make a cache for this
proc getAttrib*(shader: Shader, name: string): int32 =
  shader.use()
  result = shader.id.glGetAttribLocation(name.cstring)
  if result == -1:
    error("ShaderManager", "attrib " & name & " doesn't exist")

proc setMat*(shader: Shader, location: int32, mat: var Mat4[float32]) =
  shader.use()
  glUniformMatrix4fv(location, 1, false, mat.caddr)

proc setMat*(shader: Shader, location: int32, mat: var Mat3[float32]) =
  shader.use()
  glUniformMatrix3fv(location, 1, false, mat.caddr)

proc setMat*(shader: Shader, location: int32, mat: var Mat2[float32]) =
  shader.use()
  glUniformMatrix2fv(location, 1, false, mat.caddr)

proc setVec*(shader: Shader, location: int32, vec: var Vec4[float32]) =
  shader.use()
  glUniform4fv(location, 1, vec.caddr)

proc setVec*(shader: Shader, location: int32, vec: var Vec3[float32]) =
  shader.use()
  glUniform3fv(location, 1, vec.caddr)

proc setVec*(shader: Shader, location: int32, vec: var Vec2[float32]) =
  shader.use()
  glUniform2fv(location, 1, vec.caddr)

proc setInt*(shader: Shader, location: int32, val: int32) =
  shader.use()
  glUniform1i(location, val)
