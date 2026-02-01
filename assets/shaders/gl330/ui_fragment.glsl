#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

float gradientNoise(in vec2 uv)
{
    return fract(52.9829189 * fract(dot(uv, vec2(0.06711056, 0.00583715))));
}

void main()
{
    vec4 texelColor = texture(texture0, fragTexCoord);
    if (texelColor.a == 0.0) discard;
    vec2 uv = ( 2. * fragTexCoord - vec2(2) ) / 2;
    vec4 outColor = texelColor * fragColor * colDiffuse;

    // Add dither to reduce color banding
    float noise = gradientNoise(gl_FragCoord.xy);
    vec3 dither = vec3(noise - 0.5) / 255.0;

    finalColor = vec4(outColor.rgb + dither.rgb, outColor.a);
}
