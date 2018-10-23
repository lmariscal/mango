// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec2 iTexCoord;

out vec2 oTexCoord;

uniform mat4 uMVP;

void
main() {
  gl_Position = uMVP * vec4(iPos, 1.0f);
  oTexCoord = iTexCoord;
}

@fragment
#version 330 core

in vec2 oTexCoord;

out vec4 FragColor;

uniform sampler2D uTexture;

@include utils

void
main() {
  FragColor = texture(uTexture, oTexCoord);
}
