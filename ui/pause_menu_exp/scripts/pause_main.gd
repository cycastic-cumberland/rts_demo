extends MenuComponent

onready var musik := $Musik
onready var bgm_tween := $Musik/Tween
onready var main_ui := $UI

export(float, 0.5, 3.0) var bgm_fade = 1.0
export(float, -60.0, 24.0, 1) var max_bgm := -30.0
var min_bgm := -80.0

func _setup():
	._setup()
	musik = $Musik
	main_ui = $UI
	musik.volume_db = min_bgm
	musik.playing = true
	var _ignore = main_ui.connect("return_to_game", self, "return_game_handler")
	_ignore = main_ui.connect("settings_menu", self, "main_menu_handler")

func _self_pushed():
	bgm_tween.interpolate_property(musik, "volume_db", min_bgm, max_bgm, bgm_fade,\
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	bgm_tween.start()
	main_ui.visible = true

func _non_self_pushed():
	main_ui.visible = false

func _self_popped():
	bgm_tween.interpolate_property(musik, "volume_db", max_bgm, min_bgm, bgm_fade,\
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	bgm_tween.start()
	main_ui.visible = false

func return_game_handler():
	if focus:
		uicm.pop_state()

func main_menu_handler():
	uicm.push_with_key("MainMenu")
