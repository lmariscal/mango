# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import ../src/mango/[window, ioman, shader, mesh, utils, logging]
import nimgl/stb_image
import nimgl/opengl
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
    # Vertices             UVs           Normals
      0.5f,  0.5f, 0.0f,   1.0f, 1.0f,   0.0f, 1.0f, 1.0f,
      0.5f, -0.5f, 0.0f,   1.0f, 0.0f,   0.0f, 1.0f, 0.0f,
     -0.5f, -0.5f, 0.0f,   0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
     -0.5f,  0.5f, 0.0f,   0.0f, 1.0f,   0.0f, 0.0f, 1.0f 
    ]

    indices: seq[uint32] = @[
      0'u32, 1, 3,
      1, 2, 3
    ]

  const
    shaderData = readShader("examples/res/shaders/color.glsl")

  var
    shadero     = createShader(shaderData)
    mesho       = createMesh(shadero.id, vertices, indices)
    uModel      = shadero.getLocation("uModel")
    uView       = shadero.getLocation("uView")
    uProjection = shadero.getLocation("uProjection")
    projection  = ortho(-4f, 4f, -3f, 3f, -1f, 1f)

  # Tex Load

  var tex: uint32
  glGenTextures(1, tex.addr);
  glBindTexture(GL_TEXTURE_2D, tex);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.int32);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.int32);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.int32);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.int32);

  let img = stbi_load("examples/res/images/box.jpg", 3)

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.int32, img.width, img.height, 0, GL_RGB, GL_UNSIGNED_BYTE, img.data);
  glGenerateMipmap(GL_TEXTURE_2D)

  img.data.stbi_image_free()

  var rot: float32 = 30

  while win.isOpen():
    # updat
    win.update()

    # draw
    clearScreen(vec3(33f).rgb())

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, tex)

    var trans = mat4identity[float32]()
    var view  = mat4identity[float32]()
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

  glDeleteTextures(1, tex.addr)
  mesho.clean()
  win.destroy()

main()
