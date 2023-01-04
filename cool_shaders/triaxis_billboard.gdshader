// NOTE: Shader automatically converted from Godot Engine 3.5.stable's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec3 billboard_axis = vec3(0.0, 1.0, 0.0);


void vertex() {
	vec3 axis = normalize(billboard_axis);
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(vec4(normalize(cross(axis, CAMERA_MATRIX[2].xyz)),0.0),vec4(axis, 0.0),vec4(normalize(cross(CAMERA_MATRIX[0].xyz, axis)),0.0),WORLD_MATRIX[3]);
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = albedo.a * albedo_tex.a;
}
