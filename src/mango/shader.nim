# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/opengl
import strutils

type
  Shader* = object
    id*: uint32
    vertex*: uint32
    fragment*: uint32

  ShaderSource* = ref object
    vertex*: cstring
    fragment*: cstring
    path*: string

converter toString(chars: seq[cchar]): string =
  result = ""
  for c in chars:
    if c == '\0': continue
    result.add(c)

proc readShader*(path: string): ShaderSource =
  let source = readFile(path)
  var
    vertex = ""
    fragment = ""
    index = 0

  for line in source.splitLines:
    if line == "@vertex":
      index = 1
      continue
    elif line == "@fragment":
      index = 2
      continue
    elif line.startsWith("//"): continue
    elif line == "": continue

    if index == 0: continue
    elif index == 1: vertex.add(line & "\n")
    elif index == 2: fragment.add(line & "\n")
  
  result = new ShaderSource
  result.path = path
  result.vertex = vertex
  result.fragment = fragment

proc statusShader*(shader: uint32, `type`: string, path: string) =
  var status: int32
  shader.glGetShaderiv(GL_COMPILE_STATUS, status.addr)
  if status != GL_TRUE.ord:
    var length: int32
    var message = newSeq[cchar](1024)
    shader.glGetShaderInfoLog(1024, length.addr, message[0].addr)
    echo "[error] failed to compile " & `type` & " shader \"" & path & "\":"
    echo message.toString()

proc createShader*(source: ShaderSource): Shader =
  result.vertex = glCreateShader(GL_VERTEX_SHADER)
  result.vertex.glShaderSource(1, source.vertex.addr, nil)
  result.vertex.glCompileShader()
  result.vertex.statusShader("vertex", source.path)

  result.fragment = glCreateShader(GL_FRAGMENT_SHADER)
  result.fragment.glShaderSource(1, source.fragment.addr, nil)
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
    echo "[error] faield to link shader program \"" & source.path & "\""
    echo message.toString()

proc createShader*(file: string): Shader =
  createShader(readShader(file))

proc use*(shader: Shader) =
  shader.id.glUseProgram()

# @TODO: Make a cache for this
proc getLocation*(shader: Shader, name: string): int32 =
  shader.use()
  result = shader.id.glGetUniformLocation(name.cstring)
  if result == -1:
    echo "[warn] uniform " & name & " doesn't exist"
