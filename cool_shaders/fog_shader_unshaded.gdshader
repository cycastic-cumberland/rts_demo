shader_type spatial;
render_mode unshaded;

uniform float strength : hint_range(0, 1000.0) = 1.0;
uniform bool inverted = false;
uniform sampler2D ramp;
uniform bool use_ramp = true;
uniform bool use_depth_as_uv = true;
uniform sampler2D albedo : hint_albedo;
uniform float albedo_modifier : hint_range(0, 10) = 1.0;
uniform vec4 intersection_color : hint_color = vec4(1.0);
uniform float intersection_blend : hint_range(0, 1) = 0.0;
uniform bool blend_alpha = false;
uniform float alpha_override : hint_range(0, 1) = 0.0;
//------------------------------------------------------------------------------
uniform bool use_surface_scrolling = false;
uniform bool use_bump_map = false;
uniform bool bump_map_noise = false;
uniform vec2 scroll_direction = vec2(1.0, 0.0);
uniform highp float scroll_speed : hint_range(0, 10) = 1.0;
uniform highp float second_scroll_mod : hint_range(1, 5) = 1.0;
uniform sampler2D bump_map : hint_normal;
uniform highp float bump_scale : hint_range(0.0001, 10.0) = 1.0;

uniform sampler2D noise_no1;


void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	depth *= 1.0 / strength;
	float in_weight = depth;
	if (inverted){
		depth = exp(-depth);
		in_weight = exp(-in_weight);
	} else {}
	vec4 main_al;
	vec4 bump;
	vec2 bump_uv = UV * vec2(bump_scale);
	vec2 noise_uv = bump_uv;
	if (use_ramp){
		if (use_depth_as_uv)
			main_al = texture(ramp, vec2(depth));
		else main_al = texture(ramp, UV);
		
	} else {
		main_al = texture(albedo, UV);
	}
	if (use_surface_scrolling){
		bump_uv += scroll_speed * TIME * normalize(scroll_direction);
		noise_uv += scroll_speed * TIME * normalize(scroll_direction) * second_scroll_mod;
	}
	bump = texture(bump_map, bump_uv);
	vec3 main_albedo = main_al.rgb;
	main_albedo = mix(main_al.rgb, intersection_color.rgb, intersection_blend * in_weight);
	if (use_bump_map){
		if (bump_map_noise)
			bump += texture(noise_no1, noise_uv);
		main_albedo *= bump.rgb;
		
	}
	main_albedo *= albedo_modifier;
	ALBEDO = main_albedo;
	ALPHA = clamp(depth, 0.0, 1.0) + alpha_override;
	if (blend_alpha){
		ALPHA *= texture(albedo, UV).r;
	}
}