extends Control

func get_random_time():
	return float(randi() % 100) / 10.0

func set_offset(children := []):
	for c in children:
		if c is PanelContainer:
			var mat: ShaderMaterial = c.material
			mat.set_shader_param("random_time", get_random_time())
			return
		else:
			set_offset(c.get_children())

func _ready():
	randomize()
	set_offset(get_children())
