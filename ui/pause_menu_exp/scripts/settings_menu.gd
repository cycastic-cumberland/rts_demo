extends MenuComponent

const ALPHA_PATH := "material:shader_param/alpha"

onready var curtain := $bg1
onready var curtain_tween := $bg1/Tween

export(float, 0.1, 2.0) var curtain_fade_time := 0.1

func _setup():
	._setup()

func fade_curtain(reversed := false):
	if not reversed:
		curtain_tween.interpolate_property(curtain, ALPHA_PATH,\
			0.0, 1.0, curtain_fade_time,\
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		(curtain.material as ShaderMaterial).set_shader_param("alpha", 1.0)
	else:
		curtain_tween.interpolate_property(curtain, ALPHA_PATH,\
			1.0, 0.0, curtain_fade_time,\
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		(curtain.material as ShaderMaterial).set_shader_param("alpha", 0.0)
	curtain_tween.start()
#	if reversed:
#		yield(get_tree().create_timer(curtain_fade_time), "timeout")
#		visible = false

func _self_pushed():
	._self_pushed()
	fade_curtain()

func _self_popped():
#	._self_popped()
	fade_curtain(true)
