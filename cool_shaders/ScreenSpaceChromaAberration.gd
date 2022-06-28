extends Control

onready var rect := $ColorRect

export(float, 0.0, 1.0) var amount := 0.0 setget set_amount
export(float, 0.0, 10.0) var offset_scroll_speed := 1.0
export(Texture) var offset_texture: Texture = null setget set_texture
export(bool) var use_real_offset := false

var is_ready := false

func set_amount(a: float):
	amount = a
	if is_ready:
		var shader: ShaderMaterial = rect.material
		shader.set_shader_param("amount", a)

func set_scroll_speed(speed: float):
	offset_scroll_speed = speed
	if is_ready:
		var shader: ShaderMaterial = rect.material
		shader.set_shader_param("scroll_speed", offset_scroll_speed)
		if speed == 0.0:
			shader.set_shader_param("scroll_offset", false)
		else:
			shader.set_shader_param("scroll_offset", true)

func set_texture(tex: Texture):
	offset_texture = tex
	if is_ready:
		var shader: ShaderMaterial = rect.material
		shader.set_shader_param("offset_texture", tex)
		if not is_instance_valid(tex):
			shader.set_shader_param("use_texture", false)
		else:
			shader.set_shader_param("use_texture", true)

func set_rear(yes: bool):
	use_real_offset = yes
	if is_ready:
		var shader: ShaderMaterial = rect.material
		shader.set_shader_param("use_rear_offset", yes)

func _ready():
	is_ready = true
	set_amount(amount)
	set_scroll_speed(offset_scroll_speed)
	set_texture(offset_texture)
	set_rear(use_real_offset)
