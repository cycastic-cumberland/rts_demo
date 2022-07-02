extends Spatial

onready var exhaust: Particles = get_child(0)
onready var fighter: AirCombatant = get_parent()

export(float, 0.0, 1.0) var exhaust_threshold := 0.05

func _process(_delta):
	if fighter.speedPercentage > exhaust_threshold and exhaust.emitting:
		exhaust.emitting = false
	elif fighter.speedPercentage <= exhaust_threshold and not exhaust.emitting:
		exhaust.emitting = true
