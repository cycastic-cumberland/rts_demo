extends Spatial

onready var mover = $CameraYaw/CameraMover
onready var yawController = $CameraYaw
onready var pitchController = $CameraYaw/CameraMover/CameraPitch
onready var camera = $CameraYaw/CameraMover/CameraPitch/Camera

export(Curve) var cameraMovementCurve 					= preload("res://camera/CameraCurve.tres")
export(float, 5, 1000, 1) var cameraMaximumRadius		= 100.0
export(int) var regressionStartingPoint					= 1
export(float) var regressionBlend						= 0.001
export(float) var cameraMaxZoom							= 100.0
export(float) var cameraMinZoom							= 5.0
export(float) var cameraZoomSpeedPenalty				= 0.75
export(Vector2) var cameraPitchLock						= Vector2(-90.0, -5.0)
export(Vector2) var cameraYawLock						= Vector2(0.0, 0.0)
export(bool) var useZoomEquation						= false
export(bool) var disableCameraMaxRadius					= false

var pointCount: int
var regressionPoint: Vector2
var regressAt: float
var speedMod: float = 1

var globalSpeed			= 50
var globalMovement 		= Vector3(0, 0, 0)
var globalRegression 	= Vector3(0, 0, 0)
var deccelarationRate 	= 0.7

func _ready():
	setCameraExtension(cameraMaxZoom)
	var currentZoom = camera.translation.z / cameraMaxZoom
	speedMod = clamp(currentZoom, 0.0001, 1)
	recalculateCurveValues()

func outputCameraInfo():
	return ("scaling: {scale}, pitch: {pitch}, yaw: {yaw}"\
		.format({"scale": get_scale(), "pitch": pitchController.get_rotation().x, "yaw": yawController.get_rotation().y}))

func cameraZoomEquation():
	pass

func recalculateCurveValues():
	pointCount = cameraMovementCurve.get_point_count()
	regressionPoint = cameraMovementCurve.get_point_position(pointCount - regressionStartingPoint)
	regressAt = regressionPoint.x

func changeMovementCurve(newCurve: Curve):
	cameraMovementCurve = newCurve
	recalculateCurveValues()

func setCameraRotation(rot: Vector2):
	pitchController.rotation.x = rot.y;
	mover.rotation.y   = rot.x;
	
func setCameraExtension(length: float):
	camera.translation.z = length

func moveCamera(movement: Vector3, speed=globalSpeed):
	globalMovement = movement
	globalSpeed = speed

func cameraZoom(zoomScale: float):
	var zoom = clamp(camera.translation.z + zoomScale, cameraMinZoom, cameraMaxZoom)
	camera.translation.z = zoom
	var coveredPercentage = clamp((zoom) / (cameraMaxZoom), 0.0001, 1)
	var penalty = (coveredPercentage) * cameraZoomSpeedPenalty
	if penalty != 0:
		speedMod = penalty
	else:
		penalty = 1

func rotateCameraOnTheFly(rot: Vector2):
	var pitch = rot.y
	var yaw   = rot.x
	if cameraYawLock.x == cameraYawLock.y:
		mover.rotate_y(deg2rad(yaw))
	else:
		mover.rotation_degrees.y =\
			clamp(mover.rotation_degrees.y + yaw, cameraYawLock.x, cameraYawLock.y)
	pitchController.rotation_degrees.x =\
		clamp(pitchController.rotation_degrees.x + pitch, cameraPitchLock.x, cameraPitchLock.y)

func setRenderDistance(distance: float):
	camera.far = distance

func cameraTranslation1(deltaTime: float):
	var distance = translation.distance_to(mover.translation)
	if globalMovement != Vector3(0, 0, 0):
		var move = globalMovement
		var newQuat = Quat()
		var mover_angle_rad = mover.global_transform.basis.get_euler()
		var mover_angle_deg = Vector3(rad2deg(mover_angle_rad.x),\
									  rad2deg(mover_angle_rad.y),\
									  rad2deg(mover_angle_rad.z))
		newQuat.set_euler(Vector3(0.0, deg2rad(rad2deg(atan2(move.x, move.z))\
			+ mover_angle_deg.y), 0.0))
		move = (newQuat * -global_transform.basis.x)
		if not disableCameraMaxRadius:
			var new_distance = translation.distance_to(mover.translation + move)
			var percentage = new_distance / cameraMaximumRadius
			var mod
			if percentage >= 1:
				mod = 0
			else:
				mod = cameraMovementCurve.interpolate(percentage)
			if (percentage > regressAt):
				globalRegression = -(mover.translation - translation)
				globalRegression = globalRegression.normalized()
				globalRegression *= regressionBlend
				globalRegression *= (move.length() / globalRegression.length())
				globalRegression *= clamp(percentage - regressAt, 0, 1)
			move *= mod
		move *= speedMod * globalSpeed * deltaTime
		mover.translation += move
		globalMovement = Vector3()
	if (globalRegression != Vector3(0, 0, 0)):
		var percentage = distance / cameraMaximumRadius
		if percentage <= regressAt:
			globalRegression = Vector3(0, 0, 0)
		else:
			mover.translation += globalRegression

func _process(delta):
	cameraTranslation1(delta)
