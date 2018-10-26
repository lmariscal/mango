// Written by Leonardo Mariscal <leo@cav.bz>, 2018

@vertex
#version 330 core
in vec3 iPos;
in vec3 iNormal;

out vec3 oFragPos;
out vec3 oNormal;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void
main() {
  oFragPos = vec3(uModel * vec4(iPos, 1.0));
  oNormal = iNormal;  
  
  gl_Position = uProjection * uView * vec4(oFragPos, 1.0);
}

@fragment
#version 330 core
out vec4 FragColor;

in vec3 oNormal;  
in vec3 oFragPos;  
  
uniform vec3 uLightPos; 

@include utils

void
main() {
  float ambientStrength = 0.1;
  vec3 ambient = ambientStrength * vec3(1.0f, 1.0f, 1.0f);

  vec3  norm     = normalize(oNormal);
  vec3  lightDir = normalize(uLightPos - oFragPos);
  float diff     = max(dot(norm, lightDir), 0.0);
  vec3  light  = diff * vec3(1.0f, 1.0f, 1.0f);
          
  vec3 result = (ambient + light) * rgb(vec3(129.0f, 199.0f, 132.0f));
  FragColor = vec4(result, 1.0);
} 
