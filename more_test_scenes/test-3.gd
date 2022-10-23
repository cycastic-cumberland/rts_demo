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

#onready var squadron = $"Squadron-WildWeasel"
onready var squadron = $"Squadron-Db80"
onready var camera = $CameraController
onready var light = $DirectionalLight

onready var paths: Array = [
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
	new_profile.max_speed = 1500.0
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
#	handler.set_hardpoints([f.get_node("Hardpoints/Hardpoint1"),\
#							f.get_node("Hardpoints/Hardpoint2"),\
#							f.get_node("Hardpoints/Hardpoint3")])
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

var ownerless := []

func find_ownerless(start_at: Node):
	var children := start_at.get_children()
	for child in children:
		if child.owner == null or not is_instance_valid(child.owner):
			ownerless.append(child)
		find_ownerless(child)

func create_weapon_propfile():
	var profile := setup_w_profile()
	weapon_handler = setup_w_handler()
#	weapon_handler2 = setup_w_handler(fighterList1["P1"])
	for f in fighterList1:
		fighterList1[f].get_fire_control().profile = profile

func set_ownership(start_at: Node, current_iter: Node = null):
	if current_iter == null:
		current_iter = start_at
	var children := current_iter.get_children()
	for child in children:
		child.owner = start_at
		set_ownership(start_at, child)

func print_ownerless():
	find_ownerless(LevelManager.template)
	print("Ownerless:")
	for node in ownerless:
		print(node.get_path())

func test_afbcfg():
	var new_cfg := preload("res://addons/Vehicular/configs/default_afbncfg.tres")
	var old_cfg := preload("res://addons/Vehicular/configs/default_afbcfg.tres")
	for i in range(0, 5):
		var start_new := Time.get_ticks_usec()
		var _a := new_cfg.get_area_accel(0.0, 2.176)
		var end_new := Time.get_ticks_usec()
		print("Integral sampling (new method): {t} usec(s)".format({"t": end_new - start_new}))
	for i in range(0, 5):
		var start_new := Time.get_ticks_usec()
		var _a := old_cfg.get_area_accel(0.0, 2.176)
		var end_new := Time.get_ticks_usec()
		print("Integral sampling (old method): {t} usec(s)".format({"t": end_new - start_new}))

func test_afbcfg_2():
	var new_cfg := preload("res://addons/Vehicular/configs/default_afbncfg.tres")
	var start_new := Time.get_ticks_usec()
	var _a := new_cfg.get_area_accel(0.0, 2.176)
	var end_1 := Time.get_ticks_usec()
	var _b := new_cfg.accel_graph.get_area_no_bake(0.0, 2.176, AdvancedCurve.AC_TRAPEZOID)
	var end_2 := Time.get_ticks_usec()
	print("Bake: " + str(end_1 - start_new))
	print("On-the-fly: " + str(end_2 - end_1))

func _ready():
#	var def_res := preload("res://addons/Vehicular/configs/stdafbn_turn.tres")
#	print(rad2deg(def_res.get_area(0.0, 5.0)))
	get_tree().use_font_oversampling = true
	if AdvancedFighterBrain.USE_MULTITHREADS:
		var swarm: ProcessorsSwarm = SingletonManager.fetch("ProcessorsSwarm")
		var cluster := swarm.add_cluster("AFB_cluster", true, true)
	get_viewport().usage = Viewport.USAGE_3D
	get_viewport().fxaa = true
	get_viewport().sharpen_intensity = 0.5
#	get_viewport().msaa = Viewport.MSAA_16X
	lastPos = squadron.global_transform.origin
	light.directional_shadow_max_distance = 1000.0
	initAll(squadron)
	addAllFighters(squadron, fighterList1)
	addAllFlag(squadron)
	create_weapon_propfile()
	pc_count()
#	test_afbcfg()

func _exit_tree():
#	for f in fighterList1:
#		fighterList1[f].free()
#	print("Count: " + str(test_instance.count))
#	test_instance.free()
#	test_instance2.free()
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
	for m in squad.member_list:
		fighterList1[m] = null
		fighterList2[m] = null
		flagList[m] = null

func addAllFighters(squad, fl):
	for m in fl:
		fl[m] = fighter.instance()
		add_child(fl[m])
		fl[m].owner = self
		fl[m].translation = squad.member_list[m].global_transform.origin
		#---------------------------------------
		fl[m]._vehicle_config.max_speed = 800.0
		fl[m]._vehicle_config.acceleration = 8.0
		fl[m]._vehicle_config.decceleration = -0.0
		fl[m]._vehicle_config.slowingTime = 2.0
#		fl[m]._vehicle_config.acceleration = 4.0
#		fl[m]._vehicle_config.decceleration = -32.0
#		fl[m]._vehicle_config.slowingTime = 0.405
		fl[m]._vehicle_config.turnRate = 0.05
		fl[m]._vehicle_config.maxTurnRate = 0.1
#		Utilities.TrialTools.try_call(fl[m], "update_states")
		if m == "P0":
			dc.set_target(fl[m])
		if m == "P0" and playMusik:
			var audio_player = AudioStreamPlayer3D.new()
			fl[m].add_child(audio_player)
			audio_player.owner = fl[m]
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
		flagList[m].owner = self
		flagList[m].translation =\
			squad.member_list[m].global_transform.origin

func guideAllFighter(squad):
	for m in fighterList1:
		if fighterList1[m] != null:
			fighterList1[m].\
				set_course(squad.member_list[m].global_transform.origin)

func squadronTracking():
	for m in fighterList1:
		fighterList1[m].set_tracking_target(fighterList2[m])
	for m in fighterList2:
		fighterList2[m].set_tracking_target(fighterList1[m])

func relocateAllFlag(squad):
	for m in flagList:
		if flagList[m] != null:
			flagList[m].translation =\
				squad.member_list[m].global_transform.origin

func fire_stuff():
	for f in fighterList1:
		fighterList1[f].get_fire_control().fire_once()

func _fire_test(_delta: float):
	if Input.is_action_just_pressed("ui_select"):
		fire_stuff()
#		set_ownership(LevelManager.template)
#		var serialized := LevelManager.serialize_level(LevelManager.template)
#		print(serialized)
#		LevelManager.deserialize_level_debug(serialized)
#		var full_package := LevelManager.level2package(LevelManager.template)
#		LevelManager.set_level_defered(full_package)
		pass

#onready var org_size := Vector2(1920, 1080)
var ssaa_scaling := 1.0
var borderless_fullscreen := false
var normal_windows_size := Vector2.ZERO
var normal_windows_pos  := Vector2.ZERO

func _lead_test(_delta: float):
	if Input.is_action_just_pressed("ui_accept"):
#		var vec := PoolVector3Array([
#			paths[0].global_transform.origin,
#			paths[1].global_transform.origin,
#			paths[2].global_transform.origin,
#			paths[3].global_transform.origin
#		])
#		var first: VTOLFighterBrain = fighterList1[fighterList1.keys().front()]
#		first.set_multides(vec)
		borderless_fullscreen = not borderless_fullscreen
		if borderless_fullscreen:
			normal_windows_size = OS.window_size
			normal_windows_pos  = OS.window_position
		OS.window_borderless = borderless_fullscreen
		OS.window_maximized = borderless_fullscreen
		if not borderless_fullscreen:
			OS.window_size = normal_windows_size
			OS.window_position = normal_windows_pos

func _process(delta):
	loggit()
	dT = delta
	_fire_test(delta)
	_lead_test(delta)

var vg_save_path := "res://vg_graph.tres"
var vg_res := Curve.new()
var vg_timer := 0.0
var vg_interval := 0.25
var vg_started := false


func graph_plot():
	var seconds := vg_interval
	var f = (fighterList1["P0"])
	while f.isMoving:
		yield(get_tree(), "physics_frame")
		vg_timer += SingletonManager.fetch("UtilsSettings").fixed_delta
		if vg_timer >= seconds:
			seconds += vg_interval
			vg_res.add_point(Vector2(vg_timer, f.currentSpeed))
	# Save now
	vg_res.add_point(Vector2(vg_timer, 0.0))
	ResourceSaver.save(vg_save_path, vg_res)

func velocity_graph():
	if not vg_started and (fighterList1["P0"]).isMoving:
		vg_started = true
		vg_res.max_value = 3000.0
#		graph_plot()

func _physics_process(_delta):
	# _lead_test(delta)
	pcalls_count += 1
	velocity_graph()

onready var di := $DebugInfo

func loggit():
	var l_loc: Vector3
	var fighter_loc: Vector3 = fighterList1["P0"].global_transform.origin
	var angle := 0.0
	if is_instance_valid(launcher):
		l_loc = fighter_loc.direction_to(launcher.global_transform.origin)
		var f_loc: Vector3 = -fighterList1["P0"].global_transform.basis.z
		angle = f_loc.angle_to(l_loc)
	di.table = {
		"debug_build": str(OS.is_debug_build()),
		"processor_name": OS.get_processor_name(),
		"processor_count": OS.get_processor_count(),
		"graphics_device_name": VisualServer.get_video_adapter_name(),
		"graphics_device_vendor": VisualServer.get_video_adapter_vendor(),
		"memory_static_max": String().humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)),
		"memory_dynamic_max": String().humanize_size(Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX)),
		"delta": dT,
		"is_moving_1": (fighterList1["P0"]).isMoving,
		"is_moving_2": (fighterList1["P1"]).isMoving,
		"physics_calls": physics_calls,
		"borderless_fullscreen": borderless_fullscreen,
		"angle": rad2deg(angle),
		"forward": -fighterList1["P0"].global_transform.basis.z,
#		"min_ray_delta": (fighterList1["P0"]).accbs.raw_sensor_data.length(),
		"throttle": fighterList1["P0"].throttle,
		"distance": fighterList1["P0"].distance,
#		"allowed_turn": fighterList1["P0"].states["AFBSM_Steer"].allowed,
#		"states_physics_call": fighterList1["P0"].states["AFBSM_Steer"].physics_call,
		"last_location": dc.last_location,
		"last_velocity": dc.last_velocity,
		"last_direction": dc.last_direction,
		"accelaration":  dc.acceleration,
		"max_accel":  dc.max_accel,
		"turn_timer": (fighterList1["P0"] as NAFB_Standalone).pda.get_state_by_name("NAFBSS_Steer").turn_timer,
#		"speed_loss": fighterList1["P0"].realSpeedLoss,
		"missiles_left": weapon_handler.reserve,
		"ssaa_scaling": ssaa_scaling,
	}

func _input(levent):
	if not levent.is_class("InputEventMouseButton"): return
	if not levent.button_index == BUTTON_LEFT: return
	if not levent.pressed: return
	var cam = get_viewport().get_camera()
	var from: Vector3= cam.project_ray_origin(levent.position)
	var to: Vector3 = from + cam.project_ray_normal(levent.position) * 10000
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
