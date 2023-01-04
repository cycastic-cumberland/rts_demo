extends MeshInstance

export(float, 10, 1000) var subdiv_lowest	:= 10
export(float, 10, 1000) var subdiv_low		:= 50
export(float, 10, 1000) var subdiv_medium	:= 100
export(float, 10, 1000) var subdiv_high		:= 100
export(float, 10, 1000) var subdiv_highest	:= 300

export(float, 16, 4096) var res_lowest		:= 512
export(float, 16, 4096) var res_low			:= 512
export(float, 16, 4096) var res_medium		:= 1024
export(float, 16, 4096) var res_high		:= 2048
export(float, 16, 4096) var res_highest		:= 4096

onready var main_mesh := mesh as PlaneMesh
onready var mat := get_surface_material(0) as ShaderMaterial
onready var vd := mat.get_shader_param("vertex_displacement") as NoiseTexture
onready var vf := mat.get_shader_param("vertex_flowmap") as NoiseTexture

func _ready():
	SettingsServer.connect("graphics_preset_changed", self, "gp_changed")
	gp_changed(SettingsServer.current_graphics_preset)
#	$AnimationPlayer.play("Cloud noise map")

func set_res(new_res: int):
#	vd.width = new_res
#	vd.height = new_res
##
#	vf.width = new_res / 2
#	vf.height = new_res / 2
	
#	an.width = new_res
#	an.width = new_res
	pass

func job(mode: int):
	var selected_subdiv := subdiv_lowest
	var selected_res := res_lowest
	match mode:
		SettingsServer.GRAPHICS_CUSTOM: return
		SettingsServer.GRAPHICS_LOWEST:
			selected_subdiv = subdiv_lowest
			selected_res = res_lowest
		SettingsServer.GRAPHICS_LOW:
			selected_subdiv = subdiv_low
			selected_res = res_low
		SettingsServer.GRAPHICS_MEDIUM:
			selected_subdiv = subdiv_medium
			selected_res = res_medium
		SettingsServer.GRAPHICS_HIGH:
			selected_subdiv = subdiv_high
			selected_res = res_high
		SettingsServer.GRAPHICS_HIGHEST:
			selected_subdiv = subdiv_highest
			selected_res = res_highest
		_: return
	if main_mesh.subdivide_width != selected_subdiv:
		main_mesh.subdivide_width = selected_subdiv
#		main_mesh.subdivide_depth = subdiv_lowest
	set_res(selected_res)

func gp_changed(mode: int):
	job(mode)
