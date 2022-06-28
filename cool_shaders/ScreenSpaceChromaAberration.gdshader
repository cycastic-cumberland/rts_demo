shader_type canvas_item;

uniform highp float amount : hint_range(0, 1.0) = 0.0;
uniform bool use_texture = false;
uniform bool use_rear_offset = false;
uniform sampler2D offset_texture;
uniform bool scroll_offset = false;
uniform float scroll_speed : hint_range(0, 10.0) = 1.0;

const float OFFSET_X = 2.0 / 3.0;
const float OFFSET_Y = 1.0 / 3.0;

void fragment(){
	vec4 color;
	highp float real_amount = amount / 10.0;
	if (use_texture){
		vec2 uv = UV;
		if (scroll_offset)
			uv += scroll_speed * TIME * vec2(1.0, 0.0);
		real_amount *= texture(offset_texture, uv).r / 1.0;
	}
	else if (use_rear_offset){
		vec2 from_center = abs(UV - vec2(0.5, 0.5));
		float v_len = length(from_center);
		real_amount *= v_len * 2.0;
	}
	color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + (OFFSET_X * real_amount),
		SCREEN_UV.y + (OFFSET_Y * real_amount))).r;
	color.g = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x,
		SCREEN_UV.y + (OFFSET_X * real_amount))).g;
	color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - (OFFSET_X * real_amount),
		SCREEN_UV.y + (OFFSET_Y * real_amount))).b;
	color.a = 1.0;
	COLOR = color;
}