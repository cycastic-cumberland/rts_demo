extends Spatial

onready var camera = $RTSCamera

export(float) var cameraTranslationSpeed 	= 60.0
export(float) var renderDistance: float 	= 3000.0\
	setget setCameraRenderingDistance, getCameraRenderingDistance
export(float) var cameraRotationSpeed 		= 50.0
export(float) var cameraZoomSpeed 			= 500.0
export(float) var defaultCameraExtension	= 50.0
export(bool) var invertX 					= false
export(bool) var invertY 					= false
export(bool) var disableAxisMovement		= false
export(bool) var usePhysicsProcess			= true
var deltaTime: float = 0.0

func _ready():
	if get_parent():
		camera.setCameraExtension(defaultCameraExtension)
		setCameraRenderingDistance(renderDistance)
		camera.cameraMaximumRadius = 300.0

func engage(delta: float):
	deltaTime = delta
	if not disableAxisMovement:
		var movement = Vector3(0, 0, 0)
		var xSpeed = (-Input.get_action_strength("move_forward") + Input.get_action_strength("move_backward"))
		var ySpeed = (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
		movement += xSpeed * transform.basis.x
		movement += ySpeed * transform.basis.z
		movement = movement.normalized()
		if movement != Vector3(0, 0, 0):
			camera.moveCamera(movement, cameraTranslationSpeed)

func _physics_process(delta):
	if usePhysicsProcess:
		engage(delta)

func _process(delta):
	if not usePhysicsProcess:
		engage(delta)

func _input(event):
	# --------------------------------------------------------------------- #
	#----------------------------CAMERA-MOVEMENT--------------------------- #
	# --------------------------------------------------------------------- #
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			var rel = -event.relative
			camera.rotateCameraOnTheFly(rel * deltaTime * cameraRotationSpeed)
		if Input.is_action_pressed("camera_pan"):
			var cam_movement = -event.relative
			cam_movement = Vector3(cam_movement.x, 0.0, cam_movement.y)
			camera.moveCamera(cam_movement, cameraTranslationSpeed)
	var cam_zoom: float = 0.0
	if Input.is_action_pressed("camera_zoom_in"):
		cam_zoom = -deltaTime
	elif Input.is_action_pressed("camera_zoom_out"):
		cam_zoom = deltaTime
	if cam_zoom != 0.0:
		camera.cameraZoom(cam_zoom * cameraZoomSpeed)

func setCameraRenderingDistance(distance: float):
	renderDistance = distance
	camera.setRenderDistance(renderDistance)

func getCameraRenderingDistance():
	return renderDistance

func getRealCamera() -> Camera:
	return camera.camera
