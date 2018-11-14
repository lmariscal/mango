# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm
import strutils
import ../core/logger
import ../graphics

type
  Shader* = object
    program*: ShaderProgram
    path*: string

  ShaderSource* = object
    other*: cstring
    vertex*: cstring
    fragment*: cstring
    path*: string

proc readShader*(path: string): ShaderSource =
  cmlog("ShaderManager", "reading {path} shader".fmt)
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

    if line[0] == '#' and not line.startsWith("#version"):
      if line == "#vertex": index = 1
      elif line == "#fragment": index = 2
      elif line == "#other": index = 0
      elif line.startsWith("#include "):
        var name = line["#include ".len ..< line.len]
        if not name.contains('.'): name.add(".glsl")

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

proc newShader*(source: ShaderSource): Shader =
  result.program = newShaderProgram(source.vertex, source.fragment, source.path, source.path)
  mlog("ShaderManager", "loading {source.path} shader".fmt)

proc newShader*(file: string): Shader =
  newShader(readShader(file))

proc use*(shader: Shader): void =
  shader.program.use()

proc clean*(shader: Shader): void =
  shader.program.clean()

# @TODO: Make a cache for this
proc getLocation*(shader: Shader, name: string): i32 =
  result = shader.program.uniformLocation(name)
  if result == -1:
    error("ShaderManager", "{shader.path} uniform {name} doesn't exist".fmt)

# @TODO: Make a cache for this
proc getAttrib*(shader: Shader, name: string): i32 =
  result = shader.program.attribLocation(name)
  if result == -1:
    error("ShaderManager", "{shader.path} attrib {name} doesn't exist".fmt)

proc setMat*(shader: Shader, location: i32, mat: var Mat4f) =
  shader.program.uniformMatrix(location, mat)

proc setMat*(shader: Shader, location: i32, mat: var Mat3f) =
  shader.program.uniformMatrix(location, mat)

proc setMat*(shader: Shader, location: i32, mat: var Mat2f) =
  shader.program.uniformMatrix(location, mat)

proc setVec*(shader: Shader, location: i32, vec: var Vec4f) =
  shader.program.uniformVector(location, vec)

proc setVec*(shader: Shader, location: i32, vec: var Vec3f) =
  shader.program.uniformVector(location, vec)

proc setVec*(shader: Shader, location: i32, vec: var Vec2f) =
  shader.program.uniformVector(location, vec)

proc setInt*(shader: Shader, location: i32, val: i32) =
  shader.program.uniformInt(location, val)
