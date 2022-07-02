extends Node

const config: LevelConfiguration = preload("res://lvl_mgr_test/test_3.tres")

onready var lvl_mgr = SingletonManager.fetch("LevelManager")
onready var fake_bar := $FakeLoadingBar

var loading_bar_ready := false

func _ready():
	lvl_mgr.load_level(config)
#	config = null
#	lvl_mgr.connect("__changing_to_scene", self, "change_scene_handler")

func _process(_delta):
	if loading_bar_ready:
		return
	if lvl_mgr.curr_lmac.ls_status:
		remove_child(fake_bar)
		fake_bar.queue_free()
#		queue_free()
		loading_bar_ready = true

func change_scene_handler(_to):
	queue_free()
