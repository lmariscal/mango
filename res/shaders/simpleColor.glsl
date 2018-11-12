// Written by Leonardo Mariscal <leo@cav.bz>, 2018

#vertex
#version 330 core
in vec3 vPos;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void
main() {
  gl_Position = uProjection * uView * uModel * vec4(vPos, 1.0);
}

#fragment
#version 330 core
out vec4 gColor;

void
main() {
  gColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
}
