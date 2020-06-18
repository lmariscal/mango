# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import stb_image/read as stbi
import ../core/[logger, utils]
import ../graphics

type
  Texture* = object
    data*: Texture2D
    width*: i32
    height*: i32
    channels*: i32

proc newTexture*(path: string): Texture =
  var w, h, c: int
  var d: seq[u8] = stbi.load(path, w, h, c, stbi.Default)

  mlog("TextureManager", "loading {path} texture".fmt)
  result.data = newTexture2D()
  result.width = w
  result.height = h
  result.channels = c
  result.data.data(tfRGB, tfRGB, dtUByte, w.i32, h.i32, d[0].addr)
  result.data.genMipMap()

proc use*(tex: Texture, active: u32 = 0): void =
  tex.data.use(active)

proc clean*(tex: var Texture): void =
  tex.data.clean()
