extends Node

const config: LevelConfiguration = preload("res://lvl_mgr_test/test_3.tres")

onready var fake_bar := $FakeLoadingBar

var loading_bar_ready := false

func _ready():
	LevelManager.load_level(config, false, true)
#	config = null
#	lvl_mgr.connect("__changing_to_scene", self, "change_scene_handler")

func _process(_delta):
	if loading_bar_ready:
		return
	if LevelManager.curr_lmac.ls_status:
		remove_child(fake_bar)
		fake_bar.queue_free()
#		queue_free()
		loading_bar_ready = true

func change_scene_handler(_to):
	queue_free()
