extends Spatial

onready var vtol = $VTOLFighterBrain
onready var destination = $destination
onready var trackingTarget = $Spinner/Target
onready var output = $Label
onready var camera = $CameraController
onready var audio_player = $VTOLFighterBrain/AudioStreamPlayer3D

var mousePos := Vector3()
var isReady = false
var startSecondCourse = false
var selecting := 0

func selectPointer(s: int):
	if s == 0:
		selecting = 0
		trackingTarget.visible = false
		destination.visible = true
		vtol.setCourse(destination.translation)
	elif s == 1:
		selecting = 1
		trackingTarget.visible = true
		destination.visible = false
		vtol.setTracker(trackingTarget)
	elif s == -1:
		trackingTarget.visible = false
		destination.visible = false

func _ready():
	get_viewport().msaa = Viewport.MSAA_16X
	vtol.vehicleConfig["maxSpeed"] = 200.0
	vtol.vehicleConfig["decceleration"] = -8.0
	vtol.vehicleConfig["rollRate"] = 90.0
	selectPointer(-1)
	isReady = true

func _process(delta):
	output.text = makeDebugInfo()
	if Input.is_action_pressed("ui_accept"):
		selectPointer(1)

func _input(event):
	if (event.is_class("InputEventMouseButton")\
		and event.button_index == BUTTON_LEFT and event.pressed):
		var cam = get_viewport().get_camera()
		var from = cam.project_ray_origin(event.position)
		var to = from + cam.project_ray_normal(event.position) * 10000
		var space_state = get_world().direct_space_state
		var result: Dictionary = space_state.intersect_ray(from, to)
		if result.has("position"):
			var des = result["position"] + Vector3(0.0, 9.0, 0.0)
			mousePos = des
			destination.translation = des
			selectPointer(0)

func makeDebugInfo():
	var forward = -vtol.global_transform.basis.z
	var out = "fps: {fps}\nmousePos: {mpos}\nposition: {pos}\nrotation: {rot}\nangleTo: {ato}\nforward: {fwd}\nmoving: {moving}\nstartingRange: {startRange}\ndestination: {des}\nthrottle: {throt}\nthrot%: {throtp}\ndistance: {dis}\nslowingRange: {srange}\nspeed: {speed}\nroll: {roll}\nturnRate: {tur}\n"\
		.format({"fps": Engine.get_frames_per_second(), \
				 "mpos": mousePos, \
				 "pos": vtol.global_transform.origin,\
				 "rot": vtol.global_transform.basis.get_euler(),\
				 "ato": rad2deg(forward.angle_to(vtol.destination)),\
				 "fwd": -vtol.global_transform.basis.z, \
				 "moving": vtol.isMoving,\
				 "startRange": vtol.startingPoint.distance_to(vtol.destination), \
				 "des": vtol.destination, \
				 "throt": vtol.throttle, \
				 "throtp": vtol.speedPercentage, \
				 "dis": vtol.distance, \
				 "srange": vtol.slowingRange, \
				 "speed": vtol.currentSpeed, \
				 "roll": rad2deg(vtol.currentRoll), \
				 "tur": vtol.allowedTurn})
	return out

func _physics_process(delta):
#	vtol.translate(Vector3(0, 0, -0.1))
	pass
