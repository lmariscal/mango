# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/[glfw, opengl]
import ioman
import loger
import glm
import nimgl/imgui, nimgl/imgui/[impl_glfw, impl_opengl]

export imgui

type
  Window* = object
    size*: Vec2i
    raw*: GLFWWindow
    context*: ptr ImGuiContext

var
  windowsOpen: int = 0
  glfwInitiated: bool = false
  glInitiated: bool = false

proc glfwErrorEvent(error: GLFWErrorCode, description: cstring): void {.cdecl.} =
  error("GLFW", $description)

proc keyEvent(window: GLFWWindow, key: GLFWKey, scancode: int32, action: GLFWKeyAction, mods: GLFWKeyMod): void {.cdecl.} =
  ioman.keyEvent(key, action != kaRelease)

proc newWindow*(width: int32, height: int32, title: string = "Mango"): Window =
  discard glfwSetErrorCallback(glfwErrorEvent)
  if not glfwInitiated:
    lassert(glfwInit(), "failed to init glfw")
    glfwInitiated = true

  glfwDefaultWindowHints()
  glfwWindowHint(whContextVersionMajor, 4)
  glfwWindowHint(whContextVersionMinor, 1)
  glfwWindowHint(whOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(whOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(whResizable, GLFW_FALSE)

  result.raw = glfwCreateWindow(width, height, title, nil, nil)
  lassert(result.raw != nil, "failed to create window")
  result.size = vec2(width, height)

  windowsOpen.inc

  result.raw.makeContextCurrent()
  discard result.raw.setKeyCallback(keyEvent)

  if not glInitiated:
    lassert(glInit(), "failed to init opengl")
    glInitiated = true

  glEnable(GL_DEPTH_TEST)

  result.context = igCreateContext()
  let io = igGetIO()
  discard io.fonts.addFontFromFileTTF("res/fonts/roboto_mono/robotomono-regular.ttf", 15.0f)

  assert igGlfwInitForOpenGL(result.raw, false)
  assert igOpenGL3Init()

  igStyleColorsDark()

proc update*(window: Window) =
  glfwPollEvents()
  if keyQ.isPressed() and keyLeftControl.isPressed():
    window.raw.setWindowShouldClose(true)
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

proc clearScreen*(color: Vec3) =
  glClearColor(color.r, color.g, color.b, 1.0f)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc draw*(window: Window) =
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())
  window.raw.swapBuffers()

proc isOpen*(window: Window): bool =
  not window.raw.windowShouldClose()

proc destroy*(window: Window) =
  igOpenGL3Shutdown()
  igGlfwShutdown()
  window.context.igDestroyContext()

  window.raw.destroyWindow()
  windowsOpen.dec
  if windowsOpen < 1 and glfwInitiated:
    glfwTerminate()
    glfwInitiated = false
