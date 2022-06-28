extends Spatial

# Simple RTS Camera

# Exports
export(float) var render_distance := 50.0 setget set_render_distance
export(float) var movement_speed := 100.0 setget set_speed
export(float) var clamp_distance := 500.0 setget set_clamp_distance
export(bool) var movement_clamped := false setget set_clamped
export(bool) var movement_disabled := false
export(String, "Physics", "Idle") var cycle_mode := "Physics" setget set_upp
export(Vector2) var camera_zoom_clamp := Vector2(50.0, 300.0)\
	setget set_zoom_clamp
export(Vector2) var camera_rotation := Vector2(-60.0, 0.0)\
	setget set_camera_rotation, get_camera_rotation
export(Vector2) var camera_rotation_clamp := Vector2(-90.0, -10.0)\
	setget set_camera_rotation_clamp
export(Curve) var zoom_penalty_curve: Curve = null setget set_zoom_curve

onready var clh := $CLH
onready var camera := $Translator/PitchControl/Camera

var input_taken := false
var use_physics_process := true

func set_render_distance(dis: float):
	render_distance = dis
	if not is_instance_valid(camera):
		return
	camera.far = dis

func set_speed(speed: float):
	movement_speed = speed
	if not clh:
		return
	clh.movement_speed = speed

func set_clamp_distance(dis: float):
	clamp_distance = dis
	if not clh:
		return
	clh.clamp_distance = dis

func set_clamped(c: bool):
	movement_clamped = c
	if not clh:
		return
	clh.movement_clamped = c

func set_upp(upp: String):
	use_physics_process = (upp == "Physics")
	if not clh:
		return
	clh.use_physics_process = use_physics_process

func set_zoom_clamp(c: Vector2):
	camera_zoom_clamp = c
	if not clh:
		return
	clh.camera_zoom_clamp = c

func set_zoom_curve(c: Curve):
	zoom_penalty_curve = c
	if not clh:
		return
	clh.set_zoom_curve(c)

func set_camera_rotation(r: Vector2):
	camera_rotation = r
	if not clh:
		return
	clh.set_camera_rotation(camera_rotation)

func get_camera_rotation():
	camera_rotation = clh.get_camera_rotation()

func set_camera_rotation_clamp(c: Vector2):
	camera_rotation_clamp = c
	if not clh:
		return
	clh.camera_rotation_clamp = c

func _ready():
	set_render_distance(render_distance)
	set_speed(movement_speed)
	set_clamp_distance(clamp_distance)
	set_clamped(movement_clamped)
	set_upp(cycle_mode)
	set_zoom_clamp(camera_zoom_clamp)
	set_zoom_curve(zoom_penalty_curve)
	set_camera_rotation(camera_rotation)
	set_camera_rotation_clamp(camera_rotation_clamp)

func _compute(_delta: float):
	if $Translator.global_transform.basis.z != Vector3.RIGHT:
		pass
	if not movement_disabled and not input_taken:
		var movement := Vector2()
		var fwd_speed := (-Input.get_action_strength("move_forward") +\
			Input.get_action_strength("move_backward"))
		var right_speed := (Input.get_action_strength("move_left") -\
			Input.get_action_strength("move_right"))
		movement.x = -fwd_speed
		movement.y = right_speed
		movement = movement.normalized()
		if movement != Vector2.ZERO:
			clh.move(movement)

func _process(delta):
	if not use_physics_process:
		_compute(delta)

func _physics_process(delta):
	if use_physics_process:
		_compute(delta)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			var relative = -event.relative
