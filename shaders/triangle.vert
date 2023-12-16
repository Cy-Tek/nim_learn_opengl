#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;

uniform float hOffset;

out vec3 vertexPos;

void main() {
    gl_Position = vec4(aPos.x + hOffset, aPos.yz, 1.0);
    vertexPos = gl_Position.xyz;
}