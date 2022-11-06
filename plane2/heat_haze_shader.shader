// NOTE: Shader automatically converted from Godot Engine 3.4.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx, unshaded;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform float time_simulation : hint_range(1, 1000) = 1.0;
uniform highp float strength : hint_range(0, 1) = 0.1;
uniform float speed: hint_range(0, 100) = 0.1;
uniform float margin: hint_range(0, 1) = 0.001;
uniform sampler2D noise_texture;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
//	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 0.0, 1.0), CAMERA_MATRIX[2].xyz)),0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(normalize(cross(CAMERA_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))),0.0),WORLD_MATRIX[3]);
}

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
//	vec3 noise = textureLod(noise_texture, SCREEN_UV, 0.0).rgb;
	vec3 noise = texture(noise_texture, SCREEN_UV).rgb;
	vec2 uv = SCREEN_UV;
	uv.x += clamp(cos(noise.x * TIME * speed + time_simulation) * strength, 0.0, 0.5);
	uv.y += clamp(sin(noise.y * TIME * speed + time_simulation) * strength, 0.0, 0.5);
	vec3 screen_tex = texture(SCREEN_TEXTURE, uv).rgb;
	ALBEDO = screen_tex;
}
