shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D noise_texture;
uniform sampler2D albedo_texture;
uniform highp float scroll_speed = 0.1;
uniform float combination_offset : hint_range(0.0001, 1.0) = 0.1;
uniform float noise_threshold : hint_range(0, 1) = 0.6;
uniform float uv_scale : hint_range(0, 10) = 10.0;
uniform float emission_strength : hint_range(0, 50) = 1.0;
uniform vec2 animated_uv_direction = vec2(1.0, 0.0);
uniform bool enable_emision = false;

void vertex() {
//	UV=UV * uv1_scale.xy + uv1_offset.xy;
}

float adjust_contrast(float inp, float threshold){
	float re = inp;
	if (re < threshold){
		re = 1.0;
	}
	return re;
}

void fragment(){
	vec4 noise = texture(noise_texture, UV);
	vec2 scaled_UV = UV * vec2(uv_scale);
	scaled_UV += scroll_speed * TIME * normalize(animated_uv_direction);
	vec2 scaled_UV_reversed = (UV * vec2(uv_scale)) - (scroll_speed * TIME * normalize(animated_uv_direction));
	vec4 scaled_noise_animated = texture(noise_texture, scaled_UV + vec2(combination_offset));
	vec4 scaled_noise_animated_reversed = texture(noise_texture, scaled_UV_reversed);
	vec4 combined_animated_noise = scaled_noise_animated + scaled_noise_animated_reversed;
	vec4 full_noise_combination = combined_animated_noise + noise;
	vec4 cured_noise = texture(noise_texture, full_noise_combination.xy);
	vec4 final_noise = combined_animated_noise + cured_noise;
	float albedo_scale = adjust_contrast(final_noise.x, noise_threshold);
	vec4 final_albedo = texture(albedo_texture, UV + albedo_scale);
	ALBEDO = final_albedo.rgb;
	if (enable_emision){
		EMISSION = final_albedo.rgb * emission_strength;
	}
	
}
