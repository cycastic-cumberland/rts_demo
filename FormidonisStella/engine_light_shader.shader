// NOTE: Shader automatically converted from Godot Engine 3.4.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform float emission_strength : hint_range(0, 100);
uniform float blinking_speed : hint_range(0, 50);
uniform float min_limit : hint_range(0, 1);

float scale_back(float l1, float l2, float v){
	float per = (v + 1.0) / 2.0;
	float bandwidth = l2 - l1;
	float re = (bandwidth * per) + l1;
	return re;
}

void fragment(){
	ALBEDO 	 = albedo.rgb;
	EMISSION = albedo.rbg * scale_back(min_limit, 1.0, cos(TIME * blinking_speed)) * emission_strength;
}