// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core

in vec3 iPos;
in vec2 iTexCoord;
in vec3 iNormals;

out vec2 oTexCoord;
out vec3 oNormals;
out vec3 oFragPos;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void
main() {
  oFragPos    = vec3(uModel * vec4(iPos, 1.0f));
  oTexCoord   = iTexCoord;
  oNormals    = iNormals;

  gl_Position = uProjection * uView * vec4(oFragPos, 1.0f);
}

@fragment
#version 330 core

in vec2 oTexCoord;
in vec3 oNormals;
in vec3 oFragPos;

out vec4 FragColor;

uniform sampler2D uTexture;
uniform vec3 uLightPos;

@include utils

void
main() {
  vec4 ambient = rgba(vec3(255.0f, 249.0f, 196.0f)) * 0.1f;

  vec3  norm     = normalize(oNormals);
  vec3  lightDir = normalize(uLightPos - oFragPos);
  float diff     = max(dot(norm, lightDir), 0.0f);
  vec4  diffuse  = vec4(diff * vec3(1.0f, 1.0f, 1.0f), 1.0f);  // vec3 is light color

  FragColor = texture(uTexture, oTexCoord) * (diffuse);
}
