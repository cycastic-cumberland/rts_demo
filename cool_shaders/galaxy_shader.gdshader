shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform float emission_strength : hint_range(0, 50) = 1.0;
uniform float specular : hint_range(0, 1) = 0.5;
uniform sampler2D albedo_texture;
uniform vec4 emission_color : hint_color = vec4(vec3(0.0), 1.0);
uniform float alpha_modifier : hint_range(0, 10) = 1.0;
uniform float alpha_progress : hint_range(0, 1) = 0.0;
uniform sampler2D alpha_noise;
uniform bool enable_rim = false;
uniform float rim_size : hint_range(0.001, 1.0) = 0.04;
uniform vec4 rim_color : hint_color = vec4(1.0);

void fragment(){
	vec4 albedo = texture(albedo_texture, UV);
	vec4 a_noise = texture(alpha_noise, UV);
	float cured_alpha = a_noise.r * alpha_modifier;
	float current_alpha = cured_alpha - alpha_progress;
	//---------------------------------------------------------------------
	if (enable_rim){
		float rim = current_alpha - rim_size;
		rim = floor(1.0 - rim);
		EMISSION = rim_color.rgb * rim * emission_strength;
	}
	//ALBEDO = albedo.rgb;
	EMISSION += (albedo.rgb + emission_color.rgb) * emission_strength;
	ALPHA = ceil(current_alpha);
	SPECULAR = specular;
}