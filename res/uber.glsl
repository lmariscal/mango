// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core

in vec2 aPos;

uniform mat4 uMVP;

void
main() {
  gl_Position = vec4(aPos, 0.0f, 1.0f) * uMVP;
}

@fragment
#version 330 core

out vec4 FragColor;

@include utils

void
main() {
  FragColor = rgba(vec3(102.0f, 187.0f, 106.0f));
}
