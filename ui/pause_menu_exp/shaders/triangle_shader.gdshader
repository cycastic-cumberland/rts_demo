shader_type canvas_item;

uniform int poly_count = 3;
uniform float width: hint_range(0.01, 3.0) = 1.0;
uniform float offset: hint_range(0, 1) = 0.0;
uniform float random_time = 0.0;
uniform vec4 base_color: hint_color = vec4(1.0);
uniform float base_color_dim_percentage: hint_range(0, 1) = 0.0;
uniform float dim_speed: hint_range(0, 5) = 1.0;
uniform bool solid = false;
uniform sampler2D albedo: hint_albedo;

const float PI =  3.14159265359;
const float TAU =  6.28318530718;

float Triangle(vec2 st)
{
	st = st * 2.0 - 1.0;
	
	if (poly_count > 2)
	{
		if (poly_count < 4)
		{
			st.y += 0.25;
		}
	}
	
	float angle = atan(st.x, st.y) + radians(180.0);
	float radius = TAU / float(poly_count);
	
	float dist = cos(floor(0.5 + angle / radius) * radius - angle) * length(st);
	float poly = step(width, dist);
	return 1.0 - poly;
}

void fragment(){
	float filter = Triangle(UV - vec2(0.0, offset));
	vec4 mixed_color = (base_color * texture(albedo, UV));
	vec4 color;
	if (solid) color = mixed_color;
	else
		color = mix(mixed_color, mixed_color * base_color_dim_percentage, cos((TIME + random_time) * dim_speed));
	color.a = min(filter, color.a);
	COLOR = color;
}
