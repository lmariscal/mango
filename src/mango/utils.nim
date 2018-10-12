# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import glm

proc rgba*[T](color: Vec4[T]): Vec4[T] =
  result = vec4[T](color.r / T(255f), color.g / T(255f), color.b / T(255f), color.w)

proc rgba*[T](color: Vec3[T]): Vec4[T] =
  result = vec4[T](color.r / T(255f), color.g / T(255f), color.b / T(255f), 1f)

proc rgb*[T](color: Vec3[T]): Vec3[T] =
  result = vec3[T](color.r / T(255f), color.g / T(255f), color.b / T(255f))
