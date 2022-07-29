shader_type canvas_item;

uniform float uv_scale : hint_range(0.001, 5.0) = 1.0;
uniform float threshold : hint_range(0, 1) = 0.5;
uniform float rotation_degree : hint_range(0, 360) = 0.0;
uniform vec4 base_color : hint_color = vec4(1.0);
uniform bool uv_view_mode = false;
uniform bool uv_albedo_mode = false;
uniform sampler2D albedo: hint_albedo;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment(){
	vec2 rotated_uv = rotate(UV * uv_scale, vec2(0.5), radians(rotation_degree));
	vec4 color;
	if (uv_albedo_mode)
		color = vec4(rotated_uv, 0.0, 1.0);
	else
		color = base_color * texture(albedo, UV);
	if (rotated_uv.x < threshold) color.a = 0.0;
	if (uv_view_mode)
		COLOR = vec4(rotated_uv, 0.0, 1.0);
	else
		COLOR = color;
	
}
