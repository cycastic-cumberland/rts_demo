extends Processor

class_name TestProcessor1

var timer := 0.0

func _init():
#	
	name = "TestProcessor1"

func _compute(delta):
	timer += delta
	if (timer / 5.0) == (floor(timer / 5.0)):
		Out.print_debug("It's been 5 seconds")
		pass

func _boot():
	derived_boot()

func derived_boot():
	while not terminated:
		yield(host.get_tree().create_timer(3.0), "timeout")
		Out.print_debug("It's been 3 seconds")

func _termination_handler(_proc):
	Out.print_debug("NOOO DON'T KILL ME")
