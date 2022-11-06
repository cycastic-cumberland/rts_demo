extends MeshInstance

export(float, 10, 1000) var subdiv_lowest	:= 10
export(float, 10, 1000) var subdiv_low		:= 50
export(float, 10, 1000) var subdiv_medium	:= 100
export(float, 10, 1000) var subdiv_high		:= 100
export(float, 10, 1000) var subdiv_highest	:= 300

export(float, 16, 4096) var res_lowest		:= 128
export(float, 16, 4096) var res_low			:= 256
export(float, 16, 4096) var res_medium		:= 512
export(float, 16, 4096) var res_high		:= 1024
export(float, 16, 4096) var res_highest		:= 4096

onready var main_mesh := mesh as PlaneMesh
onready var mat := get_surface_material(0) as ShaderMaterial
onready var vd := mat.get_shader_param("vertex_displacement") as NoiseTexture
onready var vf := mat.get_shader_param("vertex_flowmap") as NoiseTexture
onready var an := mat.get_shader_param("albedo_noise") as NoiseTexture

func _ready():
	SettingsServer.connect("graphics_preset_changed", self, "gp_changed")
	gp_changed(SettingsServer.current_graphics_preset)

func set_res(new_res: int):
#	vd.width = new_res
#	vd.width = new_res
#
#	vf.width = new_res / 2
#	vf.width = new_res / 2
	
	an.width = new_res
	an.width = new_res

func gp_changed(mode: int):
	match mode:
		SettingsServer.GRAPHICS_CUSTOM: return
		SettingsServer.GRAPHICS_LOWEST:
			main_mesh.subdivide_width = subdiv_lowest
			main_mesh.subdivide_depth = subdiv_lowest
			set_res(res_lowest)
		SettingsServer.GRAPHICS_LOW:
			main_mesh.subdivide_width = subdiv_low
			main_mesh.subdivide_depth = subdiv_low
			set_res(res_low)
		SettingsServer.GRAPHICS_MEDIUM:
			main_mesh.subdivide_width = subdiv_medium
			main_mesh.subdivide_depth = subdiv_medium
			set_res(res_medium)
		SettingsServer.GRAPHICS_HIGH:
			main_mesh.subdivide_width = subdiv_high
			main_mesh.subdivide_depth = subdiv_high
			set_res(res_high)
		SettingsServer.GRAPHICS_HIGHEST:
			main_mesh.subdivide_width = subdiv_highest
			main_mesh.subdivide_depth = subdiv_highest
			set_res(res_highest)
		_: return
