# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/stb/image
import ../core/[logger, utils]
import ../graphics

type
  Texture* = object
    data*: Texture2D
    width*: u32
    height*: u32
    channels*: u32

proc newTexture*(path: string): Texture =
  let img = stbiLoad(path.cstring)
  if img.data == nil:
    error("texture", "path \"{path}\" is invalid.".fmt)
    return
  mlog("TextureManager", "loading {path} texture".fmt)

  result.data = newTexture2D()
  result.width = img.width
  result.height = img.height
  result.channels = img.channels
  result.data.data(tfRGB, tfRGB, dtUByte, img.width, img.height, img.data)
  result.data.genMipMap()

  img.imageFree()

proc use*(tex: Texture, active: u32 = 0): void =
  tex.data.use(active)

proc clean*(tex: var Texture): void =
  tex.data.clean()
