# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import ioman, logger, material, mesh, shader, texture, utils, window
import glm

when defined(release):
  logMinLevel = llCrash
else:
  logMinLevel = llMango

var win: Window
var projection: Mat4f

proc resizeEvent(window: Window): void =
  projection = perspective(radians(45.0f), window.ratio(), 0.1f, 1000.0f)

proc startEditor*() =
  mlog("starting editor")
  win = newWindow(1280, 720, "Mango", decorated = true, resizable = true)
  win.resizeProc = resizeEvent
  projection = perspective(radians(45.0f), win.ratio(), 0.1f, 1000.0f)

  var
    vertices: seq[float32] = @[
      0.5f,  0.5f, 0.0f,
      0.5f, -0.5f, 0.0f,
     -0.5f, -0.5f, 0.0f,
     -0.5f,  0.5f, 0.0f,
    ]
    uvs: seq[float32] = @[
      1.0f, 1.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f,
    ]
    normals: seq[float32] = @[
      0.0f, 1.0f, 1.0f,
      0.0f, 1.0f, 0.0f,
      1.0f, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f
    ]

    indices: seq[uint32] = @[
      0'u32, 1, 3,
      1, 2, 3
    ]

  const
    shaderData = readShader("res/shaders/color.glsl")

  var
    shadero     = newShader(shaderData)
    mesho       = newMesh(shadero.id, vertices, uvs, normals, indices)
    uModel      = shadero.getLocation("uModel")
    uView       = shadero.getLocation("uView")
    uProjection = shadero.getLocation("uProjection")

  var img = newTexture("examples/res/images/box.jpg")
  var rot: float32 = 30

  while win.isOpen():
    win.update()

    win.clearScreen(rgb(33f, 33f, 33f))

    img.use()

    var trans = mat4(1.0f).translate(vec3(0.0f, 0.0f, -10.0f))
    var view  = mat4(1.0f)

    if keyR.isPressed():
      rot += 1f
      if rot >= 360:
        rot = 0f

    shadero.setMat(uModel, trans)
    shadero.setMat(uView, view)
    shadero.setMat(uProjection, projection)

    mesho.use()

    igShowDemoWindow(nil)

    win.draw()

  img.clean()
  shadero.clean()
  mesho.clean()
  win.clean()
