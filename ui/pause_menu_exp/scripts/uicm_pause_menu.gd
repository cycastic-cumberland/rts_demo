extends MCMaintainer

var is_paused := false

func _focus_no_state():
	._focus_no_state()
	_no_state_handler()

func _no_state_handler():
	._no_state_handler()
	is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		push_default()
