# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import nimgl/glfw
import glm

export glfw.GLFWKey

var
  keys: array[GLFWKey.high.ord, bool]
  mouse: array[GLFWMouseButton.high.ord, bool]
  pad: array[GLFWGamepadButton.high.ord, bool]

  rKeys: array[GLFWKey.high.ord, bool]
  rMouse: array[GLFWMouseButton.high.ord, bool]
  rPad: array[GLFWGamepadButton.high.ord, bool]

  pKeys: array[GLFWKey.high.ord, bool]
  pMouse: array[GLFWMouseButton.high.ord, bool]
  pPad: array[GLFWGamepadButton.high.ord, bool]

  mousePos: Vec2f

proc getMousePos*(): Vec2f =
  mousePos

proc keyEvent*(key: GLFWKey, pressed: bool) =
  if keys.len < key.ord or key.ord < 0: return
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
  glfwJoystickPresent(GLFWJoystick.K1.ord) == 1

proc updateGamePad*() =
  ## Only needed if you want to use gamepad
  if not gamePadPresent(): return

  var state: GLFWGamePadState
  if glfwGetGamepadState(GLFWJoystick.K1.ord, state.addr) == 1:
    for i in 0 ..< GLFWGamepadButton.low.ord:
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
