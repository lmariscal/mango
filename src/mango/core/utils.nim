# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm
import nimgl/imgui

converter toInt32*(x: uint32): int32 = x.int32
converter toInt32*(x: int): int32 = x.int32
converter toUint32*(x: int32): uint32 = x.uint32
converter toImVec4*(v: Vec4f): ImVec4 = cast[ImVec4](v)
converter toImVec2*(v: Vec2f): ImVec2 = cast[ImVec2](v)

template rgba*[T](color: Vec4[T]): Vec4[T] =
  vec4[T](color.r / T(255f), color.g / T(255f), color.b / T(255f), color.w)

template rgba*[T](r: T, g: T, b: T, a: T): Vec3[T] =
  vec4[T](r / T(255f), g / T(255f), b / T(255f), a)

template rgba*[T](color: Vec3[T]): Vec4[T] =
  vec4[T](color.r / T(255f), color.g / T(255f), color.b / T(255f), 1f)

template rgba*[T](r: T, g: T, b: T): Vec3[T] =
  vec4[T](r / T(255f), g / T(255f), b / T(255f), 1f)

template rgb*[T](color: Vec3[T]): Vec3[T] =
  vec3[T](color.r / T(255f), color.g / T(255f), color.b / T(255f))

template rgb*[T](r: T, g: T, b: T): Vec3[T] =
  vec3[T](r / T(255f), g / T(255f), b / T(255f))
