shader_type spatial;

uniform float alpha_progress : hint_range(0.0, 1) = 1.0;
uniform float alpha_modifier : hint_range(0.00001, 10.0) = 1.0;
uniform float emission_strength : hint_range(0, 20) = 1.0;
uniform float emission_modifier : hint_range(0.00001, 10) = 1.0;
uniform float albedo_lerp : hint_range(0, 1) = 0.0;
uniform sampler2D alpha_noise;
uniform sampler2D emission_noise;
uniform sampler2D explosion_glow;
uniform vec4 albedo_override : hint_color = vec4(0.0);
uniform bool enable_rim = false;
uniform float rim_size : hint_range(0.001, 1.0) = 0.04;
uniform vec4 rim_color : hint_color = vec4(0.0);

void fragment(){
	vec4 a_noise = texture(alpha_noise, UV);
	vec4 e_noise = texture(emission_noise, UV);
	vec4 exp_tex = texture(explosion_glow, vec2(e_noise.x, e_noise.y) * emission_modifier);
	vec3 albedo = mix(exp_tex.rgb, albedo_override.rgb, albedo_lerp);
	float cured_alpha = a_noise.r * alpha_modifier;
	float current_alpha = cured_alpha - alpha_progress;
	//---------------------------------------------------------------------
	if (enable_rim){
		float rim = current_alpha - rim_size;
		rim = floor(1.0 - rim);
		EMISSION = rim_color.rgb * rim * emission_strength;
	}
	ALBEDO = albedo;
	EMISSION += albedo * emission_strength;
	ALPHA = ceil(current_alpha);
//	float channel = noise.r * alpha_modifier;
//	float alpha_proc = channel - alpha_progress;
//	float rim = alpha_proc - rim_size;
//	rim = floor(1.0 - rim);
//	if (use_albedo_override)
//		ALBEDO = albedo_override.rgb;
//	else{
//		vec4 exp_tex = texture(explosion_glow, vec2(noise.x, noise.y) * emission_modifier);
//		ALBEDO = exp_tex.rgb;
//		EMISSION = exp_tex.rgb * emission_strength;
//	}
//	EMISSION = rim_color.rgb * rim * emission_strength;
//	ALPHA = ceil(alpha_proc);
}