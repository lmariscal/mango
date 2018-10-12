# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/[glfw, opengl]
import ioman
import glm

type
  Window* = object
    size*: Vec2i
    raw*: GLFWWindow

var
  windowsOpen: int = 0
  glfwInitiated: bool = false
  glInitiated: bool = false

proc keyEvent(window: GLFWWindow, key: GLFWKey, scancode: int32, action: GLFWKeyAction, mods: GLFWKeyMod): void {.cdecl.} =
  ioman.keyEvent(key, action != kaRelease)

proc createWindow*(width: int32, height: int32): Window =
  if not glfwInitiated:
    assert glfwInit()
    glfwInitiated = true

  glfwDefaultWindowHints()
  glfwWindowHint(whContextVersionMajor, 4)
  glfwWindowHint(whContextVersionMinor, 1)
  glfwWindowHint(whOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(whOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(whResizable, GLFW_FALSE)

  result.raw = glfwCreateWindow(width, height, "Mango", nil, nil)
  assert result.raw != nil
  result.size = vec2(width, height)

  windowsOpen.inc

  result.raw.makeContextCurrent()
  discard result.raw.setKeyCallback(keyEvent)

  if not glInitiated:
    assert glInit()
    glInitiated = true

proc update*(window: Window) =
  glfwPollEvents()
  if keyQ.isPressed() and keyLeftControl.isPressed():
    window.raw.setWindowShouldClose(true)

proc clearScreen*(color: Vec3) =
  glClearColor(color.r, color.g, color.b, 1.0f)
  glClear(GL_COLOR_BUFFER_BIT)

proc draw*(window: Window) =
  window.raw.swapBuffers()

proc isOpen*(window: Window): bool =
  not window.raw.windowShouldClose()

proc destroy*(window: Window) =
  window.raw.destroyWindow()
  windowsOpen.dec
  if windowsOpen < 1 and glfwInitiated:
    glfwTerminate()
    glfwInitiated = false