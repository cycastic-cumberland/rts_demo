extends Control

onready var counter = $Label

func _process(_delta):
	counter.set_text(str(Engine.get_frames_per_second()) + " FPS")
