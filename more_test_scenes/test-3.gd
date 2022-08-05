extends Spatial

class_name PlaygroundNo3

#onready var fighter = preload("res://plane1/VTOLFighter1.tscn")
export(PackedScene) var fighter = preload("res://plane2/VTOLFighter2.tscn")
export(PackedScene) var flag = preload("res://plane_icon/destination.tscn")
export(PackedScene) var bullet = preload("res://plane2/test_bullet.tscn")
export(AudioStream) var musik = preload("res://musik/ricardo_theme1.mp3")
export(bool) var playMusik = false

const USE_PLANE_EQUATION = true

onready var launcher = $Spinner2/Ricardo
onready var dc = $DistanceCompensator
onready var squadron = $"Squadron-WildWeasel"
onready var squadron2 = $Squadron2
onready var camera = $CameraController
onready var light = $DirectionalLight

onready var paths = [
	$des1, $des2, $des3, $des4
]

var mousePos := Vector3.ZERO
var lastPos: Vector3
var fighterList1: Dictionary = {}
var fighterList2: Dictionary = {}
var flagList: Dictionary = {}

var weapon_handler: WeaponHandler = null
var weapon_handler2: WeaponHandler = null

var verify_leading := false
var timer := 0.0
var predicted_loc := Vector3.ZERO
var actual_loc := Vector3.ZERO
var actual_dir := Vector3.ZERO
var deviation := 0.0
var margin := 0.0
var dT := 0.0

var cfg_path := "C:/Users/cycastic/Documents/testies_save.tres"

func setup_w_profile() -> WeaponConfiguration:
	var profile := WeaponConfiguration.new()
	profile.weapon_name = "Hawkeye"
	profile.weaponGuidance = WeaponConfiguration.GUIDANCE.FLG
	profile.weaponFireMode = WeaponConfiguration.FIRE_MODE.BARRAGE
	profile.rounds = 100
	profile.loadingTime = 1.0
	profile.seekingAngle = deg2rad(30.0)
	profile.travelSpeed = 3000.0
	profile.travelTime = 5.0
	profile.homingRange = 1000.0
	profile.proximity = 100.0
	profile.weaponProximityMode = WeaponConfiguration.PROXIMITY_MODE.DELAYED
	profile.projectile = bullet
	var new_profile := AircraftConfiguration.new()
	new_profile.acceleration = 64.0
	new_profile.turnRate = 0.05
	new_profile.maxTurnRate = 0.08
	new_profile.maxSpeed = 1500.0
	profile.dvConfig = new_profile
	return profile

func setup_w_handler(curr_fighter = fighterList1["P0"]) -> WeaponHandler:
	var handler := WeaponHandler.new()
	LevelManager.template.add_peripheral(handler)
	var profile
	profile = setup_w_profile()
#	profile = WeaponConfiguration.new()
#	profile = profile.load_res(cfg_path, profile)
	handler.profile = profile
	handler.compensation = 0.7
#	handler.pgm_target = Vector3(-153, 0, 231)
	var f: Spatial = curr_fighter
	handler.carrier = f
	handler.set_hardpoints([f.get_node("Hardpoints/Hardpoint1"),\
							f.get_node("Hardpoints/Hardpoint2"),\
							f.get_node("Hardpoints/Hardpoint3")])
	handler.target = launcher
#	handler.set_hardpoints(1, [launcher])
#	handler.target = f
	return handler

var pcalls_count := 0
var physics_calls := 0

func pc_count():
	while true:
		yield(get_tree().create_timer(1.0), "timeout")
		physics_calls = pcalls_count
		pcalls_count = 0

var cluster: ProcessorsCluster

func derived_test(a: ProcessorsCluster):
	while not a.is_ready:
		Out.print_debug("Waiting for godot...")
		yield(get_tree(), "idle_frame")
	Out.print_debug("Done!")
	a.commission()

#func steam_init():
#	var steam_status := Steam.steamInit()
#	Out.print_steamstat(steam_status["verbal"])
#	if steam_status["status"] != 1:
#		Out.print_fatal("Failed to initialize Steam, exiting")
#		get_tree().quit(0)

func _ready():
	var a := get_viewport().get_signal_connection_list("size_changed")
	for c in a:
		print(c)
	get_viewport().usage = Viewport.USAGE_3D
#	get_viewport().fxaa = true
	get_viewport().msaa = Viewport.MSAA_16X
	get_viewport().sharpen_intensity = 0.5
	lastPos = squadron.global_transform.origin
	light.directional_shadow_max_distance = 1000.0
	initAll(squadron)
	addAllFighters(squadron, fighterList1)
	addAllFlag(squadron)
	weapon_handler = setup_w_handler()
	weapon_handler2 = setup_w_handler(fighterList1["P1"])
#	var profile := weapon_handler.profile
#	var cfg_server = SingletonManager.static_services["ConfigSerializer"]
#	var serialized = cfg_server.serialize(profile)
#	pass
#	var deserialized = cfg_server.deserialize(serialized)
#	weapon_handler.profile = deserialized
#	weapon_handler2.profile = deserialized
	pc_count()
	Out.print_debug("Is it debug?: " + str(OS.is_debug_build()))
	Out.print_debug("Stack test", get_stack())

func _exit_tree():
#	for f in fighterList1:
#		fighterList1[f].free()
	pass

func set_paths():
	var p: PoolVector3Array =\
		[paths[0].global_transform.origin, \
		 paths[1].global_transform.origin, \
		 paths[2].global_transform.origin, \
		 paths[3].global_transform.origin, ]
	for f in fighterList1:
		fighterList1[f].set_course(p)

func initAll(squad):
	for m in squad.memberList:
		fighterList1[m] = null
		fighterList2[m] = null
		flagList[m] = null

func addAllFighters(squad, fl):
	for m in fl:
		fl[m] = fighter.instance()
		add_child(fl[m])
		fl[m].translation = squad.memberList[m].global_transform.origin
		#---------------------------------------
		fl[m]._vehicle_config.maxSpeed = 800.0
		fl[m]._vehicle_config.deccelaration = -32.0
		fl[m]._vehicle_config.slowingTime = 0.14
		fl[m]._vehicle_config.acceleration = 4.0
		fl[m]._vehicle_config.turnRate = 0.05
		fl[m]._vehicle_config.maxTurnRate = 0.1
		if m == "P0":
			dc.set_target(fl[m])
		if m == "P0" and playMusik:
			var audio_player = AudioStreamPlayer3D.new()
			fl[m].add_child(audio_player)
			audio_player.stream = musik
			audio_player.unit_db = 80.0
			audio_player.autoplay = true
			audio_player.play()

func addAllFlag(squad):
	for m in flagList:
		flagList[m] = flag.instance()
		flagList[m].get_node("icon").fadeDistanceStart = 100
		flagList[m].get_node("icon").fadeDistanceEnd = 180
		add_child(flagList[m])
		flagList[m].translation =\
			squad.memberList[m].global_transform.origin

func guideAllFighter(squad):
	for m in fighterList1:
		if fighterList1[m] != null:
			fighterList1[m].\
				set_course(squad.memberList[m].global_transform.origin)

func squadronTracking():
	for m in fighterList1:
		fighterList1[m].set_tracking_target(fighterList2[m])
	for m in fighterList2:
		fighterList2[m].set_tracking_target(fighterList1[m])

func relocateAllFlag(squad):
	for m in flagList:
		if flagList[m] != null:
			flagList[m].translation =\
				squad.memberList[m].global_transform.origin

func _fire_test(_delta: float):
	if Input.is_action_just_pressed("ui_select"):
		weapon_handler.fire_once()
		weapon_handler2.fire_once()

#onready var org_size := Vector2(1920, 1080)
var ssaa_scaling := 1.0

func _lead_test(delta: float):
#	if Input.is_action_just_pressed("ui_accept"):
#		ssaa_scaling = wrapf(ssaa_scaling + 0.1, 1.0, 2.0)
#		LevelManager.template.scenes_holder.size = get_viewport().size * ssaa_scaling
		pass

func _process(delta):
	loggit()
	dT = delta
	_fire_test(delta)
	_lead_test(delta)

func _physics_process(_delta):
	# _lead_test(delta)
	pcalls_count += 1
	pass

onready var di := $DebugInfo

func loggit():
	var l_loc: Vector3
	l_loc = fighterList1["P0"].global_transform.origin.direction_to(
		launcher.global_transform.origin
	)
	var f_loc: Vector3 = -fighterList1["P0"].global_transform.basis.z
	var angle := f_loc.angle_to(l_loc)
	di.table = {
		"delta": dT,
		"physics_calls": physics_calls,
		"angle": rad2deg(angle),
		"last_location": dc.last_location,
		"last_velocity": dc.last_velocity,
		"last_direction": dc.last_direction,
		"accelaration":  dc.acceleration,
		"speed_loss": fighterList1["P0"].realSpeedLoss,
		"missiles_left": weapon_handler.reserve,
		"ssaa_scaling": ssaa_scaling,
	}

func _input(event):
	if (event.is_class("InputEventMouseButton")\
			and event.button_index == BUTTON_LEFT and event.pressed):
		var cam = get_viewport().get_camera()
		var from: Vector3= cam.project_ray_origin(event.position)
		var to: Vector3 = from + cam.project_ray_normal(event.position) * 10000
		var intersection: Vector3
		if USE_PLANE_EQUATION:
			var plane_equation := GeometryMf.pe_create_pc(0, 1, 0, 0)
			var line_equation := GeometryMf.le_create_v(from, to)
			intersection = line_equation.intersect(plane_equation)
		else:
			var space_state = get_world().direct_space_state
			var result: Dictionary = space_state.intersect_ray(from, to)
			if result.has("position"):
				intersection = result["position"]
		if intersection != Vector3.ZERO and intersection != null:
			var des: Vector3 = intersection + Vector3(0.0, 20.0, 0.0)
			var oldPos: Vector3 = fighterList1["P0"].global_transform.origin
			mousePos = des
			#--------------------------------------------------------
			squadron.translation = des
			var dir = (des - oldPos).normalized()
			squadron.look_at(squadron.global_transform.origin + dir, Vector3.UP)
			relocateAllFlag(squadron)
			guideAllFighter(squadron)
