shader_type spatial;
//render_mode unshaded;

uniform float strength : hint_range(0, 1000.0) = 1.0;
uniform bool inverted = false;
uniform sampler2D ramp;
uniform bool use_ramp = true;
uniform sampler2D albedo : hint_albedo;
uniform vec4 intersection_color : hint_color = vec4(1.0);
uniform float intersection_blend : hint_range(0, 1) = 0.0;
uniform bool blend_alpha = false;
//------------------------------------------------------------------------------
uniform bool use_surface_scrolling = false;
uniform vec2 scroll_direction = vec2(1.0, 0.0);
uniform highp float scroll_speed : hint_range(0, 10) = 1.0;
uniform sampler2D surface_normal : hint_normal;
uniform highp float normal_scale : hint_range(0.0001, 10.0) = 1.0;


void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	depth *= 1.0 / strength;
//	depth = 1.1 - pow(clamp(depth, 0, 1) * (5.0 - 0.5), 1.0);
	float in_weight = depth;
	if (inverted){
		depth = exp(-depth);
		in_weight = exp(-in_weight);
	} else {}
	vec4 main_al;
	vec4 normal;
	vec2 normal_uv = UV * vec2(normal_scale);
	if (use_ramp){
		main_al = texture(ramp, vec2(depth));
		
	} else {
		main_al = texture(albedo, UV);
	}
	if (use_surface_scrolling){
		normal_uv += scroll_speed * TIME * normalize(scroll_direction);
	}
	normal = texture(surface_normal, normal_uv);
	ALBEDO = mix(main_al.rgb, intersection_color.rgb, intersection_blend * in_weight);
	NORMALMAP = normal.rgb;
	ALPHA = clamp(depth, 0.0, 1.0);
	if (blend_alpha){
		ALPHA *= texture(albedo, UV).r;
	}
}