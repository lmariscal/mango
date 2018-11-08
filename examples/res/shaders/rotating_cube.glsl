// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core
in vec3 vPos;
in vec3 vUVs;
in vec3 vNormals;

out vec3 fPos;
out vec3 fNormal;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void
main() {
  fPos = vec3(uModel * vec4(vPos, 1.0));
  fNormal = vNormals;
  
  gl_Position = uProjection * uView * vec4(fPos, 1.0);
}

@fragment
#version 330 core
out vec4 gColor;

in vec3 fNormal;  
in vec3 fPos;  
  
uniform vec3 uLightPos; 

@include utils

void
main() {
  float ambientStrength = 0.1;
  vec3 ambient = ambientStrength * vec3(1.0f, 1.0f, 1.0f);

  vec3  norm     = normalize(fNormal);
  vec3  lightDir = normalize(uLightPos - fPos);
  float diff     = max(dot(norm, lightDir), 0.0);
  vec3  light    = diff * vec3(1.0f, 1.0f, 1.0f);
          
  // vec3 result = (ambient + light) * rgb(vec3(129.0f, 199.0f, 132.0f));
  gColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
} 
