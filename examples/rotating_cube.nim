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
  let win = createWindow(800, 600, "Rotating Cube")

  var
    vertices: seq[float32] = @[
     -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
     -0.5f,  0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,

     -0.5f, -0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,
     -0.5f, -0.5f,  0.5f,

     -0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,
     -0.5f, -0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,

      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,

     -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
     -0.5f, -0.5f,  0.5f,
     -0.5f, -0.5f, -0.5f,

     -0.5f,  0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f, -0.5f
    ]
    uvs: seq[float32] = @[
      0.0f, 0.0f,
      1.0f, 0.0f,
      1.0f, 1.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,

      0.0f, 0.0f,
      1.0f, 0.0f,
      1.0f, 1.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,

      1.0f, 0.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,
      1.0f, 0.0f,

      1.0f, 0.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,
      1.0f, 0.0f,

      0.0f, 1.0f,
      1.0f, 1.0f,
      1.0f, 0.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f,

      0.0f, 1.0f,
      1.0f, 1.0f,
      1.0f, 0.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f
    ]
    normals: seq[float32] = @[
      1.0f
    ]

    indices: seq[uint32] = @[]

  const
    shaderData = readShader("examples/res/shaders/rotating_cube.glsl")

  var
    shadero = createShader(shaderData)
    mesho = createMesh(vertices, indices, uvs, normals)
    umvp = shadero.getLocation("uMVP")
    projection = ortho(-4f, 4f, -3f, 3f, -1f, 1f)

  # Tex Load

  var tex: uint32
  glGenTextures(1, tex.addr);
  glBindTexture(GL_TEXTURE_2D, tex);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.int32);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.int32);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.int32);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.int32);

  let img = stbi_load("examples/res/images/box.jpg", 3)
  log("width: {img.width}, height: {img.height}".fmt)

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.int32, img.width, img.height, 0, GL_RGB, GL_UNSIGNED_BYTE, img.data);
  glGenerateMipmap(GL_TEXTURE_2D)

  img.data.stbi_image_free()

  var rot: float32 = 0

  while win.isOpen():
    # updat
    win.update()

    # draw
    clearScreen(vec3(33f).rgb())

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, tex)

    var trans = mat4identity[float32]()
    trans = rotate(trans, rot.radians(), vec3(1f, 1f, 0f))
    rot += 1f
    if rot >= 360:
      rot = 0f
    var mvp = projection * trans
    shadero.setMat(umvp, mvp)

    mesho.use()

    win.draw()

  glDeleteTextures(1, tex.addr)
  mesho.clean()
  win.destroy()

main()
