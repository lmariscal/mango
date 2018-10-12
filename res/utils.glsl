// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@other
vec4
rgba(vec4 color) {
  return vec4(color.r / 255, color.g / 255, color.b / 255, color.a);
}

vec4
rgba(vec3 color) {
  return vec4(color.r / 255, color.g / 255, color.b / 255, 1.0);
}

vec3
rgb(vec3 color) {
  return vec3(color.r / 255, color.g / 255, color.b / 255);
}
