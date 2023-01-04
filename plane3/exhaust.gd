extends Particles

export(int, 0, 1000) var max_particles := 500

onready var fighter: AirCombatant = owner

func _ready():
	set_process(visible)

func _process(_delta):
	if Engine.get_idle_frames() % 5 == 0:
#		amount = max_particles * fighter.speedPercentage
		var res := not (fighter.speedPercentage < 0.1)
		if res != emitting: emitting = res
