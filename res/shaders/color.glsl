// Written by Leonardo Mariscal <leo@cav.bz>, 2018

#vertex
#version 330 core
in vec3 vPos;
in vec2 vUVs;
in vec3 vNormals;

out vec2 fUVs;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void
main() {
  fUVs = vUVs;
  gl_Position = uProjection * uView * uModel * vec4(vPos, 1.0);
}

#fragment
#version 330 core
in vec2 fUVs;

out vec4 gColor;

uniform sampler2D uTex;

void
main() {
  gColor = texture(uTex, fUVs);
}
