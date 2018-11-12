# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import core/[ioman, logger, utils, window], graphics/[material, mesh, shader, texture]
import editor/space
import glm

when defined(release):
  logMinLevel = llCrash
else:
  logMinLevel = llMango

var win: Window
var projection: Mat4f
var spaceo: Space

proc resizeEvent(window: Window): void =
  projection = perspective(radians(45.0f), window.ratio(), 0.1f, 1000.0f)

proc startEditor*() =
  mlog("starting editor")
  win = newWindow(1280, 720, "Mango", decorated = true, resizable = true)
  win.resizeProc = resizeEvent
  projection = perspective(radians(45.0f), win.ratio(), 0.1f, 1000.0f)
  spaceo = newSpace(16, 16)

  while win.isOpen():
    win.update()

    win.clearScreen(rgb(33f, 33f, 33f))
    spaceo.use(projection)

    win.draw()

  spaceo.clean()
  win.clean()
