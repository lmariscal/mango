# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import core/utils
export utils

type
  VertexDecl* = object
    id*: uint32
    attribs*: uint32
  VertexBuffer* = object
    id*: uint32
  IndexBuffer* = object
    id*: uint32
    len*: uint32
  Texture2D* = object
    id*: uint32
  ShaderVertex* = object
    id*: uint32
  ShaderFragment* = object
    id*: uint32
  ShaderProgram* = object
    id*: uint32
    vertex*: ShaderVertex
    fragment*: ShaderFragment
  DataUsage* = enum
    duStreamDraw
    duStreamRead
    duStreamCopy
    duStaticDraw
    duStaticRead
    duStaticCopy
    duDynamicDraw
    duDynamicRead
    duDynamicCopy
  VertexAttrib* = enum
    vaFloat1
    vaFloat2
    vaFloat3
    vaFloat4
    vaByte
    vaUByte
    vaShort
    vaUShort
    vaInt1
    vaInt2
    vaInt3
    vaInt4
    vaUInt1
    vaUInt2
    vaUInt3
    vaUInt4
    vaDouble1
    vaDouble2
    vaDouble3
    vaDouble4
  DrawMode* = enum
    dmPoints
    dmLineStrip
    dmLineLoop
    dmLines
    dmLineStripAdjacency
    dmLinesAdjacency
    dmTriangleStrip
    dmTriangleFan
    dmTriangles
    dmTriangleStripAdjacency
    dmTrianglesAdjacency
  DataType* = enum
    dtUByte
    dtUShort
    dtUInt
    tdByte
    tdShort
    tdInt
    tdFloat
  TextureTarget* = enum
    ttTexture2D
    ttProxyTexture2D
    ttTextureIdArray
    ttProxyTexture1DArray
    ttTextureRectangle
    ttProxyTextureRectangle
    ttTextureCubeMapPositiveX
    ttTextureCubeMapNegativeX
    ttTextureCubeMapPositiveY
    ttTextureCubeMapNegativeY
    ttTextureCubeMapPositiveZ
    ttTextureCubeMapNegativeZ
    ttProxyTextureCubeMap
  TextureFormat* = enum
    tfRed
    tfRG
    tfRGB
    tfBGR
    tfRGBA
    tfBGRA
    tfRedInteger
    tfRGInteger
    tfRGBInteger
    tfBGRInteger
    tfRGBAInteger
    tfBGRAInteger
    tfStencilIndex
    tfDepthComponent
    tfDepthStencil

template fSize*(num: int): int32 =
  int32(float32.sizeof * num)

template iSize*(num: int): int32 =
  int32(int32.sizeof * num)

when defined(vulkan):
  import graphics/vulkan_graphics
  export vulkan_graphics
elif defined(directx):
  import graphics/directx_graphics
  export directx_graphics
else:
  import graphics/opengl_graphics
  export opengl_graphics
