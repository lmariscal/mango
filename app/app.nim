# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/[opengl, glfw]
import mango/[window, ioman]
import glm

let win = createWindow(1280, 720)

while win.isOpen():
  win.update()
  if keyQ.isPressed() and keyLeftControl.isPressed():
    win.raw.setWindowShouldClose(true)

  glClearColor(0f, 0f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  win.draw()

win.destroy()
