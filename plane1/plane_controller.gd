extends KinematicBody

onready var body = $spaceship22

# Can't fly below this speed
var min_flight_speed = 10
# Maximum airspeed
var max_flight_speed = 50
# Turn rate
var turn_speed = 0.75
# Climb/dive rate
var pitch_speed = 0.5
# Wings "autolevel" speed
var level_speed = 3.0
# Throttle change speed
var throttle_delta = 30
# Acceleration/deceleration
var acceleration = 6.0

# Current speed
var forward_speed = 0
# Throttle input speed
var target_speed = 0
# Lets us change behavior when grounded
var grounded = false

var velocity = Vector3.ZERO
var turn_input = 0
var pitch_input = 0

func get_input(delta):
	pass
#	if Input.is_action_pressed("ui_up"):
#		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)
#	if Input.is_action_pressed("ui_down"):
#		var limit = 0 if grounded else min_flight_speed
#		target_speed = max(forward_speed - throttle_delta * delta, limit)
#
#	turn_input = 0
#	if forward_speed > 0.5:
#		turn_input -= Input.get_action_strength("move_right")
#		turn_input += Input.get_action_strength("move_left")
#
#	pitch_input = 0
#	if not grounded:
#		pitch_input -= Input.get_action_strength("move_backward")
#	if forward_speed >= min_flight_speed:
#		pitch_input += Input.get_action_strength("move_forward")

#func _physics_process(delta):
#	get_input(delta)
#	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
#	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
#	# If on the ground, don't roll the body
#	if grounded:
#		body.rotation.z = 0
#	else:
#		body.rotation.z = lerp(body.rotation.z, turn_input, level_speed * delta)
#	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
#	velocity = -transform.basis.z * forward_speed
#	# Handle landing/taking off
#	if is_on_floor():
#		if not grounded:
#			rotation.x = 0
#		velocity.y -= 1
#		grounded = true
#	else:
#		grounded = false
#
#	velocity = move_and_slide(velocity, Vector3.UP)
