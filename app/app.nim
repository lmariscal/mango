# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import mango/[window, ioman, shader, mesh, utils]
import glm

type
  Person = object
    name: string
    age: int32

proc main() =
  let win = createWindow(1280, 720)

  var
    vertices: seq[float32] = @[ -0.5f,  0.5f,
                                 0.5f,  0.5f,
                                 0.5f, -0.5f,
                                -0.5f, -0.5f ]
    indices: seq[uint32] = @[ 0'u32, 1'u32, 3'u32,
                              1'u32, 2'u32, 3'u32 ]

  const
    shader_data = readShader("res/uber.glsl")

  let
    shadero = createShader(shader_data)
    mesho = createMesh(vertices, indices)
    umvp = shadero.getLocation("uMVP")

  var mvp = ortho(-8f, 8f, -4.5f, 4.5f, -1f, 1f)

  while win.isOpen():
    # updat
    win.update()

    # draw
    clearScreen(vec3(33f).rgb())

    shadero.setMat(umvp, mvp)
    mesho.use()

    win.draw()

  win.destroy()

main()
