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
  fPos = vec3(uModel * vec4(vPos, 1.0f));
  fNormals = mat3(transpose(inverse(uModel))) * vNormals;
  fUVs = vUVs;

  gl_Position = uProjection * uView * vec4(fPos, 1.0f);
}

#fragment
#version 330 core
out vec4 gColor;

in vec2 fUVs;
in vec3 fPos;

uniform sampler2D uGrass;
uniform sampler2D uStone;

void
main() {
  float c = ((fPos.y + 5.0f) * 10.0f) / 255.0f;
  float y = fPos.y;
  if (y > 7.0f)
    gColor = texture(uStone, fUVs) * vec4(vec3(c), 1.0f);
  else if (y >= 5.0f)
    gColor = mix(texture(uGrass, fUVs), texture(uStone, fUVs), (y / 10.0f) * 1.3f) * vec4(vec3(c), 1.0f);
  else
    gColor = texture(uGrass, fUVs) * vec4(vec3(c), 1.0f);
}
