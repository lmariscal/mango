# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm
import nimgl/imgui

type
  i64* = int64
  i32* = int32
  i16* = int16
  i8*  = int8
  u64* = uint64
  u32* = uint32
  u16* = uint16
  u8*  = uint8
  f32* = float32
  f64* = float64

converter toI32*(x: u32): i32 = x.i32
converter toI32*(x: int): i32 = x.i32
converter toU32*(x: i32): u32 = x.u32
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
