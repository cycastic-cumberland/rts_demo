extends Spatial

const self_destruct := preload("res://addons/utils/self_destruct.gd")

onready var explosion1: Particles = $Exp
onready var exp_mat: ShaderMaterial = $Exp.material_override

onready var tween_fp := $Exp/FP
onready var tween_emission := $Exp/Emission

var ani_lifetime := 3.0

var progress_time := 0.5
var emission_time := 1.0

const FP_PATH := "material_override:shader_param/flipbook_progress"
const E_PATH :=  "material_override:shader_param/emission_strength"

func z_offset(amount: float):
	$Exp.translation = Vector3(0.0, 0.0, amount)

func play():
	explosion1.emitting = true
	explosion1.lifetime = ani_lifetime
	tween_fp.interpolate_property($Exp, FP_PATH, 0, 1, progress_time,\
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_emission.interpolate_property($Exp, E_PATH, 5.0, 1.0, emission_time,\
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_fp.start()
	tween_emission.start()
#	player.play("Explosion-NoCombine")
	var sd := self_destruct.new()
	sd.objects.append(self)
	sd.destruct(ani_lifetime, get_tree())
