# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/opengl
import mango/[window, ioman, shader, mesh]
import glm

proc main() =
  let win = createWindow(1280, 720)

  var
    vertices: seq[float32] = @[ -0.5f,  0.5f,
                                 0.5f,  0.5f,
                                 0.5f, -0.5f,
                                -0.5f, -0.5f ]
    indices: seq[uint32] = @[ 0'u32, 1'u32, 3'u32,
                              1'u32, 2'u32, 3'u32 ]

  let
    shadersrc = readShader("res/uber.glsl")
    shadero = createShader(shadersrc)
    mesho = createMesh(vertices, indices)
    umvp = shadero.getLocation("uMVP")

  var mvp = ortho(-8f, 8f, -4.5f, 4.5f, -1f, 1f)

  while win.isOpen():
    # updat
    win.update()

    # draw
    glClearColor(0.13f, 0.13f, 0.13f, 1.0f)
    glClear(GL_COLOR_BUFFER_BIT)

    shadero.use()
    glUniformMatrix4fv(umvp, 1, false, mvp.caddr)
    mesho.use()

    win.draw()

  win.destroy()

main()
