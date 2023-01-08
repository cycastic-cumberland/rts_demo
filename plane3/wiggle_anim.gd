extends AnimationPlayer

const MAIN_ANIM := "Idle Wiggle"
var COMPUTE_DELAY: int = clamp(ProjectSettings.get_setting("game/compute_delay"), 1, 5)

export(NodePath) var aircraft := NodePath()
onready var _aircraft: AirCombatant = get_node_or_null(aircraft)

func _ready():
	get_animation(MAIN_ANIM).loop = true
	play(MAIN_ANIM)

	var random_idx := randf()
	advance(current_animation_length * random_idx)
	set_physics_process(_aircraft != null)

func _physics_process(_delta):
	if Engine.get_physics_frames() % COMPUTE_DELAY != 0:
		return
	var speed_percent := _aircraft.speedPercentage
	playback_speed = 1.0 - speed_percent
