# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/stb/image
import nimgl/opengl
import loger

type
  Texture = object
    id*: uint32

proc newTexture*(path: string): Texture =
  let img = stbiLoad(path.cstring)
  if img.data == nil:
    error("texture", "path \"{path}\" is invalid.".fmt)
    return
  mlog("TextureManager", "loading {path} texture".fmt)

  glGenTextures(1, result.id.addr)
  glBindTexture(GL_TEXTURE_2D, result.id)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.int32)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.int32)

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.int32, img.width, img.height, 0, GL_RGB, GL_UNSIGNED_BYTE, img.data)
  glGenerateMipmap(GL_TEXTURE_2D)

  img.imageFree()

proc use*(tex: Texture, active: uint32 = 0): void =
  glActiveTexture(GL_TEXTURE0 + active)
  glBindTexture(GL_TEXTURE_2D, tex.id)

proc clean*(tex: var Texture): void =
  glDeleteTextures(1, tex.id.addr)
