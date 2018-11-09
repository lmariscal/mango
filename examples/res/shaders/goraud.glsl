// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core
layout (location = 0) in vec3 vPos;
layout (location = 1) in vec2 vUVs;
layout (location = 2) in vec3 vNormals;

out vec3 fColor;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;
uniform vec3 uLightPos;
uniform vec3 uLightColor;
uniform vec3 uObjectColor;

void main() {
  vec3 fPos = vec3(uModel * vec4(vPos, 1.0f));
  vec3 fNormals = mat3(transpose(inverse(uModel))) * vNormals;

  float ambientStrength = 0.1f;
  vec3 ambient = ambientStrength * vec3(1.0f, 1.0f, 1.0f);

  vec3  norm     = normalize(fNormals);
  vec3  lightDir = normalize(uLightPos - fPos);
  float diff     = max(dot(norm, lightDir), 0.0f);
  vec3  diffuse  = diff * uLightColor;

  fColor = (ambient + diffuse) * uObjectColor;

  gl_Position = uProjection * uView * vec4(fPos, 1.0f);
}

@fragment
#version 330 core
out vec4 gColor;

in vec3 fColor;

void
main() {
  gColor = vec4(fColor, 1.0f);
}
