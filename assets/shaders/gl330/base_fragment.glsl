#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

float tintThreshold = 0.90;
float tintSoftness = 0.08;

void main()
{
  vec4 texelColor = texture(texture0, fragTexCoord);
  if (texelColor.a == 0.0) discard;
  finalColor = texelColor * fragColor * colDiffuse;
}
