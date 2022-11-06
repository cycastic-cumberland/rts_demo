shader_type canvas_item;

uniform vec4 albedo : hint_color = vec4(1.0);

void fragment(){
	COLOR = albedo;
}
