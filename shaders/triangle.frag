#version 330 core

out vec4 FragColor;
in vec3 vertexPos;

void main() {
    float gamma = 2.2;
    vec3 gammaCorrected = pow(vertexPos, vec3(1.0 / gamma));
    FragColor = vec4(gammaCorrected, 1.0);
} 