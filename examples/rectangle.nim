# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import mango
import glm

type
  Person = object
    name: string
    age: int32

proc main() =
  when defined(release):
    logMinLevel = llCrash
  else:
    logMinLevel = llMango

  log("starting...")
  let win = newWindow(800, 600, "Rectangle")

  var
    vertices: seq[float32] = @[
      0.5f,  0.5f, 0.0f,
      0.5f, -0.5f, 0.0f,
     -0.5f, -0.5f, 0.0f,
     -0.5f,  0.5f, 0.0f,
    ]
    uvs: seq[float32] = @[
      1.0f, 1.0f,   0.0f, 1.0f, 1.0f,
      1.0f, 0.0f,   0.0f, 1.0f, 0.0f,
      0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
      0.0f, 1.0f,   0.0f, 0.0f, 1.0f
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
    shaderData = readShader("examples/res/shaders/color.glsl")

  echo shaderData.vertex

  var
    shadero     = newShader(shaderData)
    mesho       = newMesh(shadero.id, vertices, uvs, normals, indices)
    uModel      = shadero.getLocation("uModel")
    uView       = shadero.getLocation("uView")
    uProjection = shadero.getLocation("uProjection")
    projection  = ortho(-4f, 4f, -3f, 3f, -1f, 1f)

  # Tex Load

  var img = newTexture("examples/res/images/box.jpg")
  var rot: float32 = 30

  while win.isOpen():
    # updat
    win.update()

    # draw
    clearScreen(vec3(33f).rgb())

    img.use()

    var trans = mat4(1.0f)
    var view  = mat4(1.0f)
    trans = rotate(trans, rot.radians(), vec3(0f, 0f, 1f))

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
  win.destroy()

main()
