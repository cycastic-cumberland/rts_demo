extends Particles

onready var fighter: AirCombatant = owner

export(float, 0.01, 0.9, 0.01) var start_exhaustion_at := 0.5

func _ready():
	set_process(visible)
	emitting = false

func _process(_delta):
	if Engine.get_idle_frames() % 5 == 0:
#		amount = max_particles * fighter.speedPercentage
		var res := not (fighter.speedPercentage < start_exhaustion_at)
		if res != emitting: emitting = res
