@vertex
#version 330 core

in vec2 aPos;

uniform mat4 uMVP;

void main() {
  gl_Position = vec4(aPos, 0.0, 1.0) * uMVP;
}

@fragment
#version 330 core

out vec4 FragColor;

void main() {
  FragColor = vec4(0.0f, 0.5f, 0.2f, 1.0f);
}
