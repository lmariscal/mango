# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import core/[ioman, logger, utils, window], graphics/[material, mesh, shader, texture]
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

  while win.isOpen():
    win.update()

    win.clearScreen(rgb(33f, 33f, 33f))

    igShowDemoWindow(nil)

    win.draw()

  win.clean()
