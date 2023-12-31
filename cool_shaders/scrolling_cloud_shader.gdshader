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

uniform bool use_foam = true;
uniform bool use_depth = true;
uniform float foam_length : hint_range(0.001, 1.0) = 0.3;
uniform vec4 foam_color : hint_color;
uniform float depth_strength : hint_range(0.001, 500.0) = 1.0;
uniform float vdisp_modifier : hint_range(0, 500) = 1.0;
uniform float vdisp_height : hint_range(-200, 200) = 0.0;
uniform highp float vdisp_flow_speed : hint_range(0, 10) = 1.0;
uniform vec2 vdisp_flow_dir = vec2(1.0, 0.0);
uniform sampler2D vertex_displacement : hint_albedo;
uniform sampler2D vertex_flowmap : hint_albedo;
uniform highp float albedo_strength : hint_range(0.00001, 200.0) = 1.0;
uniform highp float albedo_downscale : hint_range(0.00001, 200.0) = 1.0;
uniform sampler2D visibility_map;
uniform float visibility_progress : hint_range(0, 1) = 0.0;

varying float displacement_y;
varying float visibility;
void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec2 uv_flow = UV;
	uv_flow += (vdisp_flow_speed * TIME) * normalize(vdisp_flow_dir);
	uv_flow += (texture(vertex_flowmap, UV).r * 2.0) - 1.0;

	visibility = texture(visibility_map, UV).r;
	visibility -= (visibility_progress - 0.5);
	visibility = round(visibility);

	float disp = (texture(vertex_displacement, uv_flow).r * vdisp_modifier) + vdisp_height;
	displacement_y = disp * clamp(visibility, 0.0, 1.0);
	VERTEX.y = disp;
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	depth *= 1.0 / depth_strength;
	depth =  clamp(depth, 0.0, 1.0);
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
//	vec3 main_col = albedo.rgb * albedo_tex.rgb * texture(albedo_noise, base_uv).rgb * albedo_strength;
	vec3 main_col = albedo.rgb * albedo_tex.rgb * (vec3(displacement_y + albedo_strength) / albedo_downscale);
	if (use_depth){
		if (use_foam){
			if (depth < foam_length) ALBEDO = mix(foam_color.xyz, main_col, depth / foam_length);
			else ALBEDO = main_col * vec3(depth);
		}
		else {
			 ALBEDO = main_col * vec3(depth);
		}
	}
	else {
		ALBEDO = main_col;
	}
	ALPHA = albedo.a * albedo_tex.a * visibility;
	ALPHA = clamp(ALPHA, 0.0, 1.0);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
