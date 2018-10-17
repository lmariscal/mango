# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import mango/[window, ioman, shader, mesh, utils, logging]
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
  let win = createWindow(800, 600)

  var
    vertices: seq[float32] = @[ -0.5f,  0.5f,
                                 0.5f,  0.5f,
                                 0.5f, -0.5f,
                                -0.5f, -0.5f ]
    indices: seq[uint32] = @[ 0'u32, 1'u32, 3'u32,
                              1'u32, 2'u32, 3'u32 ]

  const
    shaderData = readShader("res/uber.glsl")

  let
    shadero = createShader(shaderData)
    mesho = createMesh(vertices, indices)
    umvp = shadero.getLocation("uMVP")

  var mvp = ortho(-4f, 4f, -3f, 3f, -1f, 1f)

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
