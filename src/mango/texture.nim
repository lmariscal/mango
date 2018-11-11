# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/stb/image, nimgl/opengl

type
  Texture = object
    id*: uint32

proc newTexture*(path: string): Texture =
  let data = stbiLoad(path.cstring)
  glGenTextures(1, result.id.addr)
