extends Control

class_name PauseMenuUI

export(NodePath) var button_group_path := ""

onready var button_group := get_node_or_null(button_group_path)

signal return_to_game()
signal settings_menu()

func return_handler():
	emit_signal("return_to_game")

func settings_menu_handler():
	emit_signal("settings_menu")
