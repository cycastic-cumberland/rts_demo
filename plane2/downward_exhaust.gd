extends Spatial

onready var exhaust: Particles = get_child(0)
onready var fighter: AirCombatant = get_parent().get_parent()

export(float, 0.0, 1.0) var exhaust_threshold := 0.05
export(float, 0.1, 5.0, 0.1) var check_interval := 0.5

var stop := false

func _ready():
	run()

func _exit_tree():
	stop = true

func run():
	while not false:
		run_check()
		yield(Out.timer(check_interval), "timeout")

func run_check():
	var perc := fighter.speedPercentage
	if perc > exhaust_threshold:
		exhaust.emitting = false
	elif perc <= exhaust_threshold:
		exhaust.emitting = true
