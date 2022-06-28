extends Node

# Camera Logic Handler

# Parent's exports
var movement_speed := 100.0
var clamp_distance := 500.0 setget set_clamp_distance
var movement_clamped := false
var use_physics_process := true
var camera_zoom_clamp := Vector2(50.0, 300.0)
var camera_rotation_clamp := Vector2(-90.0, -10.0)
var zoom_penalty_curve = null setget set_zoom_curve

onready var anchor: Spatial		= get_parent()
onready var translation_control := anchor.get_node("Translator")
onready var pitch_control 		:= anchor.get_node("Translator/PitchControl")
onready var camera				:= anchor.get_node("Translator/PitchControl/" +
												   "Camera")

var cd_squared := 250000.0
var move_request := Vector2.ZERO setget set_target
var speed_penalty := 1.0

# Change every time a new destination is set or camera's yaw is changed
var fwd_vec := Vector2.UP
var angle_from_fwd := 0.0

# Builtin getter/setter
func set_zoom_curve(curve: Curve):
	zoom_penalty_curve = curve

func set_clamp_distance(dis: float):
	clamp_distance = dis
	cd_squared = dis * dis

func set_target(tar: Vector2):
	reset_vector_info(tar)
	move_request = tar

# Public functions
func set_camera_zoom(level: float) -> void:
	zoom_camera(level - camera.translation.z)

func zoom_camera(amount: float) -> void:
	var new_zoom := clamp(camera.translation.z + amount, \
		camera_zoom_clamp.x, camera_zoom_clamp.y)
	camera.translation.z = new_zoom
	if is_instance_valid(zoom_penalty_curve):
		var coverage := new_zoom / camera_zoom_clamp.y
		speed_penalty =  zoom_penalty_curve.interpolate(coverage)

func set_camera_rotation(r: Vector2) -> void:
	var pitch := deg2rad(r.y)
	var yaw   := deg2rad(r.x)
	rotate_camera(Vector2(pitch - pitch_control.rotation.x, \
						  yaw - translation_control.rotation.y))

func get_camera_rotation() -> Vector2:
	return Vector2(translation_control.rotation.y, pitch_control.rotation.x)

func rotate_camera(r: Vector2) -> void:
	var pitch := r.y
	var yaw   := r.x
	translation_control.rotate_y(yaw)
	if yaw != 0.0:
		reset_vector_info()
	if camera_rotation_clamp.x == camera_rotation_clamp.y:
		pitch_control.rotation.x = camera_rotation_clamp.x
	else:
		pitch_control.rotation.x = \
			clamp(pitch_control.rotation.x + pitch, \
			camera_rotation_clamp.x, camera_rotation_clamp.y)

func move(to: Vector2) -> void:
	set_target(to)

# Internal logic
func rotaion_loop_back(rot: float) -> float:
	if rot > 2.0 * PI:
		return (2.0 * PI) - rot
	elif rot < 0.0:
		return (2.0 * PI) + rot
	return rot

func reset_vector_info(target := move_request):
	var trans_fwd: Vector3 = -translation_control.global_transform.basis.z
	fwd_vec = Vector2(trans_fwd.x, trans_fwd.z)
	angle_from_fwd = fwd_vec.angle_to(target)
	if fwd_vec.angle() > target.angle():
		angle_from_fwd = -angle_from_fwd

func _compute(delta: float):
	var movement_vec := fwd_vec.rotated(angle_from_fwd)
	var movement_dir := Vector3(movement_vec.x, 0.0, movement_vec.y)
	var actual_movment := movement_dir * (movement_speed * delta)
	if movement_clamped:
		var distance_squared := anchor.translation.distance_squared_to\
			(translation_control.translation)
		var new_mover_trans: Vector3 = translation_control.global_transform\
			.origin + actual_movment
		if distance_squared > cd_squared and\
			new_mover_trans.distance_to(anchor.global_transform.origin) >\
			distance_squared:
				actual_movment = Vector3.ZERO
	move_request = Vector2.ZERO
	translation_control.global_translate(actual_movment)

func cycle(delta: float):
	if move_request == Vector2.ZERO:
		return
	_compute(delta)

# Overidden functions
func _ready():
	cd_squared = clamp_distance * clamp_distance

func _process(delta):
	if not use_physics_process:
		cycle(delta)

func _physics_process(delta):
	if use_physics_process:
		cycle(delta)
