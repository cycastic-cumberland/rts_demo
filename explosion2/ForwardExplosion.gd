extends Spatial

signal finished()

export(float, 0.01, 1.0) var progress_percentile := 0.16666
export(float, 0.01, 1.0) var emission_percentile := 0.33333

onready var explosion1: Particles = $Exp
onready var exp_mat: ShaderMaterial = $Exp.material_override

var animation_lifetime := 3.0
var pt1
var pt2

const FP_PATH := "material_override:shader_param/flipbook_progress"
const E_PATH :=  "material_override:shader_param/emission_strength"

func z_offset(amount: float):
	explosion1.translation = Vector3(0.0, 0.0, amount)

func make_kaboom():
	play()

func _exit_tree():
	if pt1 == null: pt1 = weakref(null)
	if pt2 == null: pt2 = weakref(null)
	while pt1.get_ref() != null or pt2.get_ref() != null:
		yield(get_tree(), "idle_frame")

func play():
	var progress_time := 0.5
	var emission_time := 1.0
	progress_time = animation_lifetime * progress_percentile
	emission_time = animation_lifetime * emission_percentile
	
	explosion1.emitting = true
	explosion1.lifetime = animation_lifetime

	pt1 = get_tree().create_tween()\
		.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
		.tween_property(explosion1, FP_PATH, 1.0, progress_time)
	pt1 = weakref(pt1)
	pt2 = get_tree().create_tween()\
		.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
		.tween_property(explosion1, E_PATH, 0.0, emission_time)
	pt2 = weakref(pt2)
	yield(Out.timer(animation_lifetime), "timeout")
	emit_signal("finished")
	queue_free()
