// Written by Leonardo Mariscal <leo@cav.bz>, 2018

#vertex
#version 330 core
layout (location = 0) in vec3 vPos;
layout (location = 1) in vec2 vUVs;
layout (location = 2) in vec3 vNormals;

out vec2 fUVs;
out vec3 fPos;
out vec3 fNormals;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void main() {
  fUVs = vUVs;
  fPos = vec3(uModel * vec4(vPos, 1.0f));
  fNormals = mat3(transpose(inverse(uModel))) * vNormals;

  gl_Position = uProjection * uView * vec4(fPos, 1.0f);
}

#fragment
#version 330 core
out vec4 gColor;

in vec2 fUVs;
in vec3 fPos;
in vec3 fNormals;

uniform sampler2D uTex;
uniform sampler2D uNormal;
uniform vec3 uLightPos;
uniform vec3 uLightColor;
uniform vec3 uObjectColor;
uniform vec3 uCamPos;

#include utils.glsl

void
main() {
  float ambientStrength = 0.1f;
  float specularStrength = 0.5f;
  vec3 ambient = ambientStrength * vec3(1.0f, 1.0f, 1.0f);

  vec3  norm     = normalize(fNormals);
  vec3  lightDir = normalize(uLightPos - fPos);
  float diff     = max(dot(norm, lightDir), 0.0f);
  vec3  diffuse  = diff * uLightColor;

  vec3  viewDir    = normalize(uCamPos - fPos);
  vec3  reflectDir = reflect(-lightDir, norm);
  float spec       = pow(max(dot(viewDir, reflectDir), 0.0f), 32);
  vec3  specular   = specularStrength * spec * uLightColor;

  gColor = texture(uTex, fUVs) * vec4((ambient + diffuse + specular) * rgb(vec3(255.0f, 255.0f, 255.0f)), 1.0f);
}
