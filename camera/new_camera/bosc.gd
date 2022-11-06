# Bounded Over the Shoulder Camera

extends Spatial

class_name BoudedOvertheShoulderCamera

const QUAD_CIRCLE := (PI / 2.0)

# Scene references
onready var yaw			:= $Yaw
onready var pitch		:= $Yaw/Mover/Pitch
onready var mover		:= $Yaw/Mover
onready var spring_arm	:= $Yaw/Mover/Pitch/SpringArm
onready var camera		:= $Yaw/Mover/Pitch/SpringArm/Camera

# Exports
export(int, "Standard", "Interpolated") var camera_type := 0
export(int, "Mouse", "Joystick") var axis_input_trigger := 0
export(int, "Keyboard", "Joystick") var translation_input_trigger := 0
export(float, -90.0, 90.0, 0.1) var max_pitch := 90.0
export(float, -90.0, 90.0, 0.1) var min_pitch := 0.0
export(float, 0.1, 20.0, 0.1) var yaw_speed := 1.0
export(float, 0.1, 20.0, 0.1) var pitch_speed := 1.0
export(float, 0.0, 2000.0, 0.1) var zoom_speed := 100.0
export(float, 0.1, 500.0, 0.1) var min_zoom := 10.0
export(float, 0.1, 8192.0, 0.1) var render_distance := 100.0 \
	setget set_render_distance
export(float, 1.0, 179.0, 0.1) var fov := 70.0 \
	setget set_fov
export(float, 0.01, 1.0, 0.01) var accelaration_diminishment := 0.5
export(float, 10.0, 1000.0, 0.1) var camera_panning_speed := 100.0
export(float, 0.1, 1000.0, 0.1) var camera_translation_speed := 1.0
export(float, 10.0, 800.0, 0.1) var camera_swiveling_speed := 50.0
export(float, 10.0, 10000.0, 0.1) var camera_extension := 100.0 \
	setget set_camera_extension
export(float, 0.01, 5.0, 0.01) var translation_minimum_step := 0.5
export(float, 0.01, 10.0, 0.01) var zoom_minimum_step := 1.0

export(Vector2) var starting_rotation		:= Vector2.ZERO
export(Vector3) var starting_location		:= Vector3.ZERO

export(bool)	var translation_enabled		:= true
export(String)	var input_panning			:= "camera_pan"
export(String)	var input_rotating			:= "camera_rotate"
export(String)	var input_zoom_in			:= "camera_zoom_in"
export(String)	var input_zoom_out			:= "camera_zoom_out"
export(String)	var input_move_forward		:= "move_forward"
export(String)	var input_move_backward		:= "move_backward"
export(String)	var input_move_port			:= "move_left"
export(String)	var input_move_starboard	:= "move_right"

# Internal values
var is_ready := false

var translation_queue := Vector2.ZERO
var current_translation := Vector2.ZERO
var translation_timer := 0.0
var translation_modifier := 1.0

var max_iterated_zoom := 0.0
var current_zoom := 0.0
var zoom_timer := 0.0
var zoom_modifier := 1.0

# Boilerplate
func _ready():
	is_ready = true
	set_camera_extension(camera_extension)
	set_render_distance(render_distance)
	set_fov(fov)
	# -------------------------------------
	mover.global_translate(starting_location - mover.global_transform.origin)
	var lower := -deg2rad(max_pitch)
	var upper := -deg2rad(min_pitch)
	pitch.rotation.x = clamp(deg2rad(starting_rotation.y), lower, upper)
	mover.rotation.y = deg2rad(starting_rotation.x)

func set_camera_extension(ex: float):
	camera_extension = ex
	if is_ready: spring_arm.spring_length = camera_extension

func set_fov(new_fov: float):
	fov = new_fov
	if is_ready: camera.fov = fov

func set_render_distance(rd: float):
	render_distance = rd
	if is_ready: camera.far = render_distance

# Inputs handler
func _input(event):
	match axis_input_trigger:
		0: if event is InputEventMouseMotion: mouse_movement_handler(event)
		1: if event is InputEventJoypadMotion: joystick_movement_handler(event)
		_: pass
	var zoom_mod := 0.0
	if Input.is_action_pressed(input_zoom_in):
		zoom_mod -= 1.0
	if Input.is_action_pressed(input_zoom_out):
		zoom_mod += 1.0
	if zoom_mod != 0.0: zoom_handler(zoom_mod, get_physics_process_delta_time())

# Events handler
func mouse_movement_handler(event: InputEvent):
	if Input.is_action_pressed(input_panning):
		pan_camera(event.relative)
	if Input.is_action_pressed(input_rotating):
		rotate_camera(-event.relative)

func joystick_movement_handler(_event: InputEvent):
	if Input.is_action_pressed(input_panning):
		pass
	if Input.is_action_pressed(input_rotating):
		pass

func pan_handler():
	pass

# Inner logics
func pan_camera(_axis: Vector2):
	pass

func zoom_handler(dir: float, delta: float):
	zoom_timer = clamp(zoom_timer - delta, 0.0, zoom_minimum_step)
	if current_zoom != 0.0:
		var change := smoothstep(0.0, max_iterated_zoom, zoom_timer / zoom_minimum_step)
		if current_zoom < 0.0: current_zoom = -change
		else: current_zoom = change
		current_zoom = clamp(current_zoom, 0.0, INF)
	elif dir == 0.0: return
	else:
		current_zoom = dir * zoom_modifier * zoom_speed
		max_iterated_zoom = current_zoom
	if current_zoom <= 0.001 and current_zoom >= -0.001:
		zoom_timer = zoom_minimum_step
		current_zoom = 0.0
		return
	spring_arm.spring_length = (clamp(spring_arm.spring_length + current_zoom, min_zoom, camera_extension))

func rotate_camera(axis: Vector2):
	var delta := get_process_delta_time()
	var p_amount := axis.y
	var y_amount := axis.x
	var lower := -deg2rad(max_pitch)
	var upper := -deg2rad(min_pitch)
	var rot: float = pitch.rotation.x
	rot += (p_amount * delta * pitch_speed)
	rot = clamp(rot, lower, upper)
	pitch.rotation.x = rot
	# pitch.rotate_x(p_amount * delta)
	mover.rotate_y(y_amount * delta * yaw_speed)

func translate_camera(delta: float):
	if current_translation == translation_queue and current_translation == Vector2.ZERO:
		translation_timer = clamp(translation_timer - (translation_minimum_step * accelaration_diminishment * delta), 0.0, accelaration_diminishment)
		return
	translation_timer = clamp(translation_timer + delta, 0.0, translation_minimum_step)
	var new_trans := Vector2.ZERO
	# Smoothly iterate the translation
	new_trans.x = smoothstep(abs(current_translation.x), abs(translation_queue.x), translation_timer / translation_minimum_step)
	new_trans.y = smoothstep(abs(current_translation.y), abs(translation_queue.y), translation_timer / translation_minimum_step)
	if translation_queue.x < 0.0: new_trans.x = - new_trans.x
	if translation_queue.y < 0.0: new_trans.y = - new_trans.y
	current_translation = new_trans#.normalized()
	# Reset the queue
	translation_queue = Vector2.ZERO
	# Actually translate the thing
	var fwd_vec:  Vector3 = -mover.global_transform.basis.z
	var cardinal_fwd := Vector3.FORWARD
	var angle_to := cardinal_fwd.signed_angle_to(fwd_vec, Vector3.UP)
	var composited_vector := Vector3(-current_translation.x, 0.0, current_translation.y).rotated(Vector3.UP, angle_to - QUAD_CIRCLE)
	composited_vector *= camera_translation_speed
	mover.global_translate(composited_vector)

func standard_translation(delta: float):
	var fwd_vec:  Vector3 = -mover.global_transform.basis.z
	var cardinal_fwd := Vector3.FORWARD
	var angle_to := cardinal_fwd.signed_angle_to(fwd_vec, Vector3.UP)
	var composited_vector := Vector3(-translation_queue.x, 0.0, translation_queue.y).normalized().rotated(Vector3.UP, angle_to - QUAD_CIRCLE)
	composited_vector *= camera_translation_speed
	mover.global_translate(composited_vector)
	translation_queue = Vector2.ZERO

func movement_detection():
	var movement := Vector2.ZERO
	match translation_input_trigger:
		0:
			# Axis as in Vector2's axis
			var x_axis: float = Input.get_action_strength(input_move_forward) \
				- Input.get_action_strength(input_move_backward)
			var y_axis: float = Input.get_action_strength(input_move_port) \
				- Input.get_action_strength(input_move_starboard)
			movement.x = x_axis
			movement.y = y_axis
			if x_axis < 0.0:
				pass
		1:
			pass
		_: return
	translation_queue += movement

func central_logic(delta: float):
#	translate_camera(delta)
	standard_translation(delta)

func _physics_process(delta):
	if translation_enabled: movement_detection()
	central_logic(delta)
	zoom_handler(0.0, delta)
