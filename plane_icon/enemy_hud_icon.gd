extends Spatial

export(float) var fadeDistanceStart = 50.0
export(float) var fadeDistanceEnd   = 60.0
export(float) var scaling 			= 20.0
export(bool)  var ringBlinking		= false
export(bool)  var iconBlinking		= false

onready var ic1 = $MeshInstance
onready var ic2 = $MeshInstance2

func _ready():
	ic1.get_surface_material(0).set_shader_param("billboardScale", scaling)
	ic2.get_surface_material(0).set_shader_param("billboardScale", scaling)
	
	ic1.get_surface_material(0).set_shader_param("blinking", iconBlinking)
	ic2.get_surface_material(0).set_shader_param("blinking", ringBlinking)

func setAlpha(alpha: float):
	ic1.get_surface_material(0).set_shader_param("alphaModifier", alpha)
	ic2.get_surface_material(0).set_shader_param("alphaModifier", alpha)

func _process(_delta):
	var cam = get_viewport().get_camera()
	if cam:
		var dis = global_transform.origin.distance_to(cam.global_transform.origin)
		var alpha = clamp(clamp((dis - fadeDistanceStart), 0.0, fadeDistanceEnd) / (fadeDistanceEnd - fadeDistanceStart), 0.0, 1.0)
		setAlpha(alpha)
