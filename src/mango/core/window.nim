# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/[glfw, imgui]
import ioman
import logger
import glm
import utils
import nimgl/imgui/[impl_glfw, impl_opengl]
import ../graphics

export imgui
export glfw

type
  Window* = ref object
    id*: i32
    size*: Vec2i
    fbSize*: Vec2i
    raw*: GLFWWindow
    context*: pointer # ImGuiContext
    resizeProc*: ResizeProc
  ResizeProc* = proc(window: Window): void

var
  windowsArray: seq[Window] = @[]
  glfwInitiated: bool = false
  glInitiated: bool = false

template igHI(v: f32): ImVec4 =
  ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: v)

template igMED(v: f32): ImVec4 =
  ImVec4(x: 0.455f, y: 0.198f, z: 0.301f, w: v)

template igLOW(v: f32): ImVec4 =
  ImVec4(x: 0.232f, y: 0.201f, z: 0.271f, w: v)

template igBG(v: f32): ImVec4 =
  ImVec4(x: 0.200f, y: 0.220f, z: 0.270f, w: v)

template igTEXT(v: f32): ImVec4 =
  ImVec4(x: 0.860f, y: 0.930f, z: 0.890f, w: v)

proc igCherryTheme(): void =
  # Thanks r-lyeh
  var style = igGetStyle()

  style.colors[ImGuiCol_Text]                 = igTEXT(0.78f)
  style.colors[ImGuiCol_TextDisabled]         = igTEXT(0.28f)
  style.colors[ImGuiCol_WindowBg]             = ImVec4(x: 0.13f, y: 0.14f, z: 0.17f, w: 1.00f)
  style.colors[ImGuiCol_PopupBg]              = igBG(0.9f)
  style.colors[ImGuiCol_Border]               = ImVec4(x: 0.31f, y: 0.31f, z: 1.00f, w: 0.00f)
  style.colors[ImGuiCol_BorderShadow]         = ImVec4(x: 0.00f, y: 0.00f, z: 0.00f, w: 0.00f)
  style.colors[ImGuiCol_FrameBg]              = igBG(1.00f)
  style.colors[ImGuiCol_FrameBgHovered]       = igMED(0.78f)
  style.colors[ImGuiCol_FrameBgActive]        = igMED(1.00f)
  style.colors[ImGuiCol_TitleBg]              = igLOW(1.00f)
  style.colors[ImGuiCol_TitleBgActive]        = igHI(1.00f)
  style.colors[ImGuiCol_TitleBgCollapsed]     = igBG(0.75f)
  style.colors[ImGuiCol_MenuBarBg]            = igBG(0.47f)
  style.colors[ImGuiCol_ScrollbarBg]          = igBG(1.00f)
  style.colors[ImGuiCol_ScrollbarGrab]        = ImVec4(x: 0.09f, y: 0.15f, z: 0.16f, w: 1.00f)
  style.colors[ImGuiCol_ScrollbarGrabHovered] = igMED(0.78f)
  style.colors[ImGuiCol_ScrollbarGrabActive]  = igMED(1.00f)
  style.colors[ImGuiCol_CheckMark]            = ImVec4(x: 0.71f, y: 0.22f, z: 0.27f, w: 1.00f)
  style.colors[ImGuiCol_SliderGrab]           = ImVec4(x: 0.47f, y: 0.77f, z: 0.83f, w: 0.14f)
  style.colors[ImGuiCol_SliderGrabActive]     = ImVec4(x: 0.71f, y: 0.22f, z: 0.27f, w: 1.00f)
  style.colors[ImGuiCol_Button]               = ImVec4(x: 0.47f, y: 0.77f, z: 0.83f, w: 0.14f)
  style.colors[ImGuiCol_ButtonHovered]        = igMED(0.86f)
  style.colors[ImGuiCol_ButtonActive]         = igMED(1.00f)
  style.colors[ImGuiCol_Header]               = igMED(0.76f)
  style.colors[ImGuiCol_HeaderHovered]        = igMED(0.86f)
  style.colors[ImGuiCol_HeaderActive]         = igHI(1.00f)
  style.colors[ImGuiCol_ResizeGrip]           = ImVec4(x: 0.47f, y: 0.77f, z: 0.83f, w: 0.04f)
  style.colors[ImGuiCol_ResizeGripHovered]    = igMED(0.78f)
  style.colors[ImGuiCol_ResizeGripActive]     = igMED(1.00f)
  style.colors[ImGuiCol_PlotLines]            = igTEXT(0.63f)
  style.colors[ImGuiCol_PlotLinesHovered]     = igMED(1.00f)
  style.colors[ImGuiCol_PlotHistogram]        = igTEXT(0.63f)
  style.colors[ImGuiCol_PlotHistogramHovered] = igMED(1.00f)
  style.colors[ImGuiCol_TextSelectedBg]       = igMED(0.43f)

  style.windowPadding     = ImVec2(x: 6, y: 4)
  style.windowRounding    = 0.0f
  style.framePadding      = ImVec2(x: 5, y: 2)
  style.frameRounding     = 3.0f
  style.itemSpacing       = ImVec2(x: 7, y: 1)
  style.itemInnerSpacing  = ImVec2(x: 1, y: 1)
  style.touchExtraPadding = ImVec2(x: 0, y: 0)
  style.indentSpacing     = 6.0f
  style.scrollbarSize     = 12.0f
  style.scrollbarRounding = 16.0f
  style.grabMinSize       = 20.0f
  style.grabRounding      = 2.0f

  style.windowTitleAlign.x = 0.50f

  style.colors[ImGuiCol_Border] = ImVec4(x: 0.539f, y: 0.479f, z: 0.255f, w: 0.162f)
  style.frameBorderSize  = 0.0f
  style.windowBorderSize = 1.0f

proc glfwErrorEvent(error: GLFWErrorCode, description: cstring): void {.cdecl.} =
  error("GLFW", $description)

proc keyEvent(window: GLFWWindow, key: GLFWKey, scancode: i32, action: GLFWKeyAction, mods: GLFWKeyMod): void {.cdecl.} =
  ioman.keyEvent(key, action != kaRelease)
  igGlfwKeyCallback(window, key, scancode, action, mods)

proc scrollEvent(window: GLFWWindow, xoff: f64, yoff: f64): void {.cdecl.} =
  igGlfwScrollCallback(window, xoff, yoff)

proc charEvent(window: GLFWWindow, code: u32): void {.cdecl.} =
  igGlfwCharCallback(window, code)

proc mouseEvent(window: GLFWWindow, button: GLFWMouseButton, action: GLFWMouseAction, mods: GLFWKeyMod): void {.cdecl.} =
  igGlfwMouseCallback(window, button, action, mods)

proc resizeEvent(window: GLFWWindow, width: i32, height: i32): void {.cdecl.} =
  for i in 0 ..< windowsArray.len:
    if windowsArray[i].raw == window:
      windowsArray[i].size.x = width
      windowsArray[i].size.y = height
      if windowsArray[i].resizeProc != nil:
        windowsArray[i].resizeProc(windowsArray[i])

proc frameBufferResizeEvent(window: GLFWWindow, width: i32, height: i32): void {.cdecl.} =
  mgSetViewRect(0'i32, 0'i32, width, height)

proc ratio*(window: Window): f32 =
  window.size.x.f32 / window.size.y.f32

proc newWindow*(width: i32, height: i32, title: string = "Mango", decorated: bool = true, resizable: bool = false): Window =
  result = new Window
  discard glfwSetErrorCallback(glfwErrorEvent)
  if not glfwInitiated:
    lassert(glfwInit(), "failed to init glfw")
    glfwInitiated = true

  glfwDefaultWindowHints()
  glfwWindowHint(whDecorated, if decorated: GLFW_TRUE else: GLFW_FALSE)
  glfwWindowHint(whResizable, if resizable: GLFW_TRUE else: GLFW_FALSE)
  glfwWindowHint(whContextVersionMajor, 4)
  glfwWindowHint(whContextVersionMinor, 1)
  glfwWindowHint(whOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(whOpenglProfile, GLFW_OPENGL_CORE_PROFILE)

  result.raw = glfwCreateWindow(width, height, title, nil, nil)
  lassert(result.raw != nil, "failed to create window")
  result.size = vec2(width, height)

  result.raw.makeContextCurrent()
  discard result.raw.setKeyCallback(keyEvent)
  discard result.raw.setMouseButtonCallback(mouseEvent)
  discard result.raw.setScrollCallback(scrollEvent)
  discard result.raw.setCharCallback(charEvent)
  discard result.raw.setWindowSizeCallback(resizeEvent)
  discard result.raw.setFrameBufferSizeCallback(frameBufferResizeEvent)

  if not glInitiated:
    lassert(mgInit(), "failed to init gl")
    glInitiated = true

  result.raw.getFramebufferSize(result.fbSize.x.addr, result.fbSize.y.addr)

  mgDepthTest(true)
  mgScissorTest(true)
  mgSetViewRect(0'i32, 0'i32, result.fbSize.x, result.fbSize.y)

  result.context = igCreateContext()
  let io = igGetIO()
  discard io.fonts.addFontFromFileTTF("res/fonts/roboto_mono/robotomono-regular.ttf", 16f)

  assert igGlfwInitForOpenGL(result.raw, false)
  assert igOpenGL3Init()

  igCherryTheme()
  result.id = windowsArray.len.i32
  windowsArray.add(result)

proc update*(window: Window) =
  glfwPollEvents()
  if keyQ.isPressed() and keyLeftControl.isPressed():
    window.raw.setWindowShouldClose(true)
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

proc clearScreen*(window: Window, color: Vec3) =
  mgSetScissor(0, 0, window.fbSize.x, window.fbSize.y)
  mgClearColor(color.r, color.g, color.b, 1.0f)
  mgClearBuffers()

proc draw*(window: Window) =
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())
  window.raw.swapBuffers()

proc isOpen*(window: Window): bool =
  not window.raw.windowShouldClose()

proc clean*(window: Window) =
  igOpenGL3Shutdown()
  igGlfwShutdown()
  cast[ptr ImGuiContext](window.context).igDestroyContext()

  window.raw.destroyWindow()
  windowsArray.del(window.id)

  for i in 0 ..< windowsArray.len:
    if windowsArray[i].id > window.id:
      windowsArray[i].id.dec

  if windowsArray.len < 1 and glfwInitiated:
    glfwTerminate()
    glfwInitiated = false
