import mango
import glm

type
  Person = object
    name: string
    age: i32

proc main() =
  when defined(release):
    logMinLevel = llCrash
  else:
    logMinLevel = llMango

  log("starting...")
  let win = newWindow(800, 600, "Rectangle")

  var
    vertices: seq[f32] = @[
      0.5f,  0.5f, 0.0f,
      0.5f, -0.5f, 0.0f,
     -0.5f, -0.5f, 0.0f,
     -0.5f,  0.5f, 0.0f,
    ]
    uvs: seq[f32] = @[
      1.0f, 1.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f,
    ]
    normals: seq[f32] = @[
      0.0f, 1.0f, 1.0f,
      0.0f, 1.0f, 0.0f,
      1.0f, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f
    ]

    indices: seq[u32] = @[
      0'u32, 1, 3,
      1, 2, 3
    ]

  const
    shaderData = readShader("res/shaders/color.glsl")

  var
    shadero     = newShader(shaderData)
    mesho       = newMesh(vertices, uvs, normals, indices)
    uModel      = shadero.getLocation("uModel")
    uView       = shadero.getLocation("uView")
    uProjection = shadero.getLocation("uProjection")
    projection  = ortho(-4f, 4f, -3f, 3f, -1f, 1f)

  # Tex Load

  var img = newTexture("examples/res/images/box.jpg")
  var rot: f32 = 30

  while win.isOpen():
    # updat
    win.update()

    # draw
    win.clearScreen(vec3(33f).rgb())

    img.use()

    var trans = mat4(1.0f)
    var view  = mat4(1.0f)
    trans = rotate(trans, rot.radians(), vec3(0f, 0f, 1f))

    if GLFWKey.R.isPressed():
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

main()
