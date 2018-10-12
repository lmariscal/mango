// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core

in vec2 aPos;

uniform mat4 uMVP;

void
main() {
  gl_Position = vec4(aPos, 0f, 1f) * uMVP;
}

@fragment
#version 330 core

out vec4 FragColor;

@include utils

void
main() {
  FragColor = rgba(vec3(102f, 187f, 106f));
}
