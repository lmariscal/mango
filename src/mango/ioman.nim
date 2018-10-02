# Copyright 2018, NimGL contributors.

import nimgl/glfw
import glm

export glfw.GLFWKey

var
  keys: array[keyLast.ord, bool]
  mouse: array[mbLast.ord, bool]
  pad: array[jsLast.ord, bool]

  rKeys: array[keyLast.ord, bool]
  rMouse: array[mbLast.ord, bool]
  rPad: array[jsLast.ord, bool]

  pKeys: array[keyLast.ord, bool]
  pMouse: array[mbLast.ord, bool]
  pPad: array[jsLast.ord, bool]

  mousePos: Vec2f

proc getMousePos*(): Vec2f =
  mousePos

proc keyEvent*(key: GLFWKey, pressed: bool) =
  if keys[key.ord] and not pressed:
    rKeys[key.ord] = true
  elif not keys[key.ord] and pressed:
    pKeys[key.ord] = true
  keys[key.ord] = pressed

proc mouseButtonEvent*(btn: GLFWMouseButton, pressed: bool) =
  if mouse[btn.ord] and not pressed:
    rMouse[btn.ord] = true
  elif not mouse[btn.ord] and pressed:
    pMouse[btn.ord] = true
  mouse[btn.ord] = pressed

proc mouseEvent*(pos: Vec2f) =
  mousePos = pos

proc gamePadPresent*(): bool =
  glfwJoystickPresent(js1)

proc updateGamePad*() =
  ## Only needed if you want to use gamepad
  if not gamePadPresent(): return

  var state: GLFWGamePadState
  if glfwGetGamepadState(js1, state.addr):
    for i in 0 ..< gpLast.ord:
      let pressed = state.buttons[i]
      if pad[i] and not pressed:
        rPad[i] = true
      elif not pad[i] and pressed:
        pPad[i] = true
      mouse[i] = pressed

proc isPressed*(key: GLFWKey): bool =
  keys[key.ord]

proc isPressed*(btn: GLFWMouseButton): bool =
  mouse[btn.ord]

proc isPressed*(btn: GLFWJoyStick): bool =
  pad[btn.ord]

proc isJustReleased*(key: GLFWKey): bool =
  if not rKeys[key.ord]: return false
  rKeys[key.ord] = false
  true

proc isJustReleased*(btn: GLFWMouseButton): bool =
  if not rMouse[btn.ord]: return false
  rMouse[btn.ord] = false
  true

proc isJustReleased*(btn: GLFWJoyStick): bool =
  if not rPad[btn.ord]: return false
  rPad[btn.ord] = false
  true

proc isJustPressed*(key: GLFWKey): bool =
  if not pKeys[key.ord]: return false
  pKeys[key.ord] = false
  true

proc isJustPressed*(btn: GLFWMouseButton): bool =
  if not pMouse[btn.ord]: return false
  pMouse[btn.ord] = false
  true

proc isJustPressed*(btn: GLFWJoyStick): bool =
  if not pPad[btn.ord]: return false
  pPad[btn.ord] = false
  true
