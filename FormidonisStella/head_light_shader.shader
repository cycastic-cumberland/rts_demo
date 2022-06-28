// NOTE: Shader automatically converted from Godot Engine 3.4.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform float emission_strength : hint_range(0, 100);
uniform float blinking_speed : hint_range(0, 10);

void fragment(){
	ALBEDO 	 = albedo.rgb;
	EMISSION = albedo.rgb * cos(TIME * blinking_speed) * emission_strength;
}