extends Node

const config: LevelConfiguration = preload("res://lvl_mgr_test/test_3.tres")

onready var lvl_mgr = SingletonManager.fetch("LevelManager")
onready var fake_bar := $FakeLoadingBar

var loading_bar_ready := false

func _ready():
	lvl_mgr.load_level(config)

func _process(_delta):
	if loading_bar_ready:
		return
	if lvl_mgr.curr_lmac.ls_status:
		remove_child(fake_bar)
		loading_bar_ready = true
