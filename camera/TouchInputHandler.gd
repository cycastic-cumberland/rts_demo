extends Node2D

signal on_screen_drag(index, position, relative, speed)
signal on_screen_touched(index, position)
signal on_screen_untouched(index, position)
signal on_screen_tapped(position)

var last_touch_position: Vector2

func _input(event):
	if event is InputEventScreenDrag:
		emit_signal("on_screen_drag", event.index, event.position, event.relative, event.speed)
	if event is InputEventScreenTouch:
		if event.pressed:
			last_touch_position = event.position
			emit_signal("on_screen_touched", event.index, event.position)
		else:
			emit_signal("on_screen_untouched", event.index, event.position)
			if event.position == last_touch_position:
				emit_signal("on_screen_tapped", last_touch_position)
	
