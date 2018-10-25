// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec2 iTexCoord;
layout (location = 2) in vec3 iNormals;

out vec2 oTexCoord;
out vec3 oNormals;

uniform mat4 uMVP;

void
main() {
  gl_Position = uMVP * vec4(iPos, 1.0f);
  oTexCoord   = iTexCoord;
  oNormals    = iNormals;
}

@fragment
#version 330 core

in vec2 oTexCoord;
in vec3 oNormals;

out vec4 FragColor;

uniform sampler2D uTexture;

@include utils

void
main() {
  vec4 ambient = rgba(vec3(255.0f, 249.0f, 196.0f)) * 0.1f;
  FragColor = texture(uTexture, oTexCoord) * ambient;
}
