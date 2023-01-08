extends Spatial

onready var exhaust: Particles = get_child(0)

export(NodePath) var fighter := NodePath()
onready var _fighter: AirCombatant = get_node_or_null(fighter)

export(float, 0.0, 1.0) var exhaust_threshold := 0.05
export(float, 0.1, 5.0, 0.1) var check_interval := 0.5

var stop := false

func search_parent():
	var curr := get_parent()
	while curr != null:
		if curr is AirCombatant:
			_fighter = curr
			break
		else:
			curr = curr.get_parent()

func _ready():
	if !_fighter:
		search_parent()
	run()

func _exit_tree():
	stop = true

func run():
	while not false:
		run_check()
		yield(Out.timer(check_interval), "timeout")

func run_check():
	var perc := _fighter.speedPercentage
	if perc > exhaust_threshold:
		exhaust.emitting = false
	elif perc <= exhaust_threshold:
		exhaust.emitting = true
