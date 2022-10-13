extends Spatial

const self_destruct := preload("res://addons/utils/automation/self_destruct.gd")

export(float, 0.01, 1.0) var progress_percentile := 0.16666
export(float, 0.01, 1.0) var emission_percentile := 0.33333

onready var explosion1: Particles = $Exp
onready var exp_mat: ShaderMaterial = $Exp.material_override

var animation_lifetime := 3.0

const FP_PATH := "material_override:shader_param/flipbook_progress"
const E_PATH :=  "material_override:shader_param/emission_strength"

func z_offset(amount: float):
	explosion1.translation = Vector3(0.0, 0.0, amount)

func make_kaboom():
	play()

func play():
	var progress_time := 0.5
	var emission_time := 1.0
	progress_time = animation_lifetime * progress_percentile
	emission_time = animation_lifetime * emission_percentile
	
	explosion1.emitting = true
	explosion1.lifetime = animation_lifetime

	var _discarded

	_discarded = get_tree().create_tween()\
		.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
		.tween_property(explosion1, FP_PATH, 1.0, progress_time)
	_discarded = get_tree().create_tween()\
		.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
		.tween_property(explosion1, E_PATH, 0.0, emission_time)
	_discarded = null
	yield(Out.timer(animation_lifetime), "timeout")
	queue_free()
