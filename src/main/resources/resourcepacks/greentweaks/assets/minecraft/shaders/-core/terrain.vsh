#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp(uv / 256.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0)));
}

void main() {
    vec3 pos = Position + ModelOffset;
    float xs = 0.0;
    float ys = 0.0;
    float zs = 0.0;

	// If pi is defined, it is something that we care about waving.
#ifdef PI
	// Common variable declaration
	vec3 position = Position / 2.0 * PI;
    float animation = GameTime * 4000.0;
	float alpha = texture(Sampler0, UV0).a * 255.0;
    float m0 = distance(Position.xz, vec2(8.0, 8.0)) * 10.0;

	// From here, we check which wavy logic we should be using
	// Cutout is plants
#ifdef CUTOUT
    if (alpha == 1.0 || alpha == 253.0) { // Most plants like grass and flowers use this
        xs = sin(position.x + animation);
        zs = cos(position.z + position.y + animation);

    } else if (alpha == 2.0) { // Used for the edges of multi-blocks, like the top block of tall grass or the bottom block of twisting vines
        xs = sin(position.x + position.y + animation) * 2.0;
        zs = cos(position.z + position.y + animation) * 2.0;

    } else if (alpha == 3.0) { // Used for spore blossoms' special animation
        xs = sin(position.x + position.y + animation);
        zs = cos(position.z + position.y + animation);
        ys = sin(position.y + (animation / 1.5)) / 9.0;
	} else if (alpha == 4.0) { // Used for vines when Wavy Leaves is enabled
        xs = sin(position.x + (position.y / 2.0) + animation);
        zs = cos(position.z + (position.y / 2.0) + animation);

    } else if (alpha == 5.0) { // Used for lily pads when Wavy Water is enabled
        xs = sin(position.x + animation) * cos(GameTime * 300);
        ys = cos(m0 + animation) * 0.65;
        zs = cos(position.z + animation) * sin(GameTime * 300);

    }

#endif

	// Cutout Mipped is leaves
#ifdef CUTOUT_MIPPED
    if (alpha == 1.0 || alpha == 2.0 || alpha == 253.0) {
        xs = sin(position.x + (position.y / 2.0) + animation);
        zs = cos(position.z + (position.y / 2.0) + animation);

    }
    if (alpha == 2.0) {
        xs *= 2.0;
        zs *= 2.0;

    }
#endif

	// Translucent is water
#ifdef TRANSLUCENT
    if (Color.r < Color.b) {
        xs = sin(position.x + animation) * cos(GameTime * 300);
        ys = cos(m0 + animation) * 0.65;
        zs = cos(position.z + animation) * sin(GameTime * 300);
    }
#endif

#endif

    gl_Position = ProjMat * ModelViewMat * (vec4(pos, 1.0) + vec4(xs / 32.0, ys / 24.0, zs / 32.0, 0.0));

    vertexDistance = fog_distance(pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
}
