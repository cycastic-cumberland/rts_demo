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
onready var squadron = $"Squadron-Db40"
#onready var camera = $CameraController
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
#	var profile := WeaponConfiguration.new()
#	profile.weapon_name = "Hawkeye"
#	profile.weaponGuidance = WeaponConfiguration.GUIDANCE.IHG
#	profile.weaponFireMode = WeaponConfiguration.FIRE_MODE.BARRAGE
#	profile.rounds = 100
#	profile.loadingTime = 1.0
#	profile.weaponArmTime = 0.8
#	profile.seekingAngle = deg2rad(40.0)
#	profile.travelSpeed = 3000.0
#	profile.travelTime = 5.0
#	profile.homingRange = 2000.0
#	profile.proximity = 100.0
#	profile.weaponProximityMode = WeaponConfiguration.PROXIMITY_MODE.DELAYED
#	profile.projectile = bullet
	var profile: WeaponConfiguration = preload("res://addons/EpicDogfight" + \
		"/profiles/default_weapon_config.tres").duplicate()
	profile.projectile = bullet
#	var new_profile := AircraftConfiguration.new()
#	new_profile.climbRate = 300.0
#	new_profile.acceleration = 6400.0
#	new_profile.turnRate = 0.05
#	new_profile.maxTurnRate = 0.08
#	new_profile.max_speed = 1500.0
#	profile.dvConfig = new_profile
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
	weapon_handler = fighterList1["P0"].get_fire_control()
	for f in fighterList1:
		var fc := fighterList1[f].get_fire_control() as WeaponHandler
		fc.profile = profile
		fc.target = launcher

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

var shutdown := false
var cf: Future = Future.new()

func test_future_pool(host, list: Dictionary, from: int, to: int):
	var last_usec := Time.get_ticks_usec()
	while not host.shutdown:
		var delta := get_physics_process_delta_time()
		var curr_usec := Time.get_ticks_usec()
		if curr_usec - last_usec < delta: continue
		last_usec = curr_usec
		for i in range(from, to):
			var key: String = list.keys()[i]
			var afb: NAFB_Standalone = list[key]
			afb.state_automaton.poll(delta)

class TestChip extends RCSChip:
	
	func _boot():
		print("Hello World to: " + str(get_host().get_id()))
		print("Fetched: ", Sentrience.combatant_get_combined_transform(get_host()))
	pass

var crid: RID
var srid: RID

var engine_debug_enabled := false
var debug_threaded := false
var debug_loop_count = 5000
var debug_loop_stage = 0
var rcs_test := preload("res://tests/test_rcs.gd")

func gut_test():
	if engine_debug_enabled:
		for i in range(0, debug_loop_count):
			var test_chip := Node.new()
			test_chip.set_script(rcs_test)
			add_child(test_chip)
			test_chip.test_team_affiliation()
			test_chip.test_general()
			test_chip.queue_free()
			debug_loop_stage += 1
			if not debug_threaded:
				yield(get_tree(), "idle_frame")

var my_watcher

func print_this():
	for i in range(1000):
		for j in range(1000):
			pass
	print("HELLO WORLD")
	return 3

func test_stuff():
	var cq := ExecutionLoop.new()
	cq.assign_instance(self)
	var a = "print_this"
	var epoch := Time.get_ticks_usec()
	cq.call_dispatched(a)
	var end := Time.get_ticks_usec()
	print("Dispatch time: " + str(end - epoch))
	cq.sync()
	var finish := Time.get_ticks_usec()
	print("Sync time: " + str(finish - end))
	return 0

func _ready():
#	print(preload("res://test_team_rel.tres").relationship == RCSUnilateralTeamProfile.TeamAllies)
#	for a in get_property_list():
#		if not (a['usage'] & 8192):
#			continue
#		print(a)
	test_stuff()
	my_watcher = Sentrience.memcontext_create()
	Sentrience.set_active(true)
	var chip := TestChip.new()
	var combatant := Sentrience.combatant_create()
	var simulation := Sentrience.simulation_create()
	crid = combatant
	srid = simulation
	print(launcher.transform)
	assert(Sentrience.combatant_assert(combatant))
	Sentrience.simulation_set_active(simulation, true)
	Sentrience.combatant_set_local_transform(combatant, launcher.transform)
	print(Sentrience.combatant_get_local_transform(combatant))
	Sentrience.combatant_bind_chip(combatant, chip, true)
	Sentrience.combatant_set_simulation(combatant, simulation)
	var id := combatant.get_id()
#	get_viewport().debanding = true
#	SettingsServer.set_main_viewport(get_viewport())
	SettingsServer.current_graphics_preset = SettingsServer.GRAPHICS_HIGH
#	var def_res := preload("res://addons/Vehicular/configs/stdafbn_turn.tres")
#	print(rad2deg(def_res.get_area(0.0, 5.0)))
	get_tree().use_font_oversampling = true
	if AdvancedFighterBrain.USE_MULTITHREADS:
		var swarm: ProcessorsSwarm = SingletonManager.fetch("ProcessorsSwarm")
		var cluster := swarm.add_cluster("AFB_cluster", true, true)
#	get_viewport().usage = Viewport.USAGE_3D
#	get_viewport().msaa = Viewport.MSAA_16X
#	get_viewport().fxaa = true
#	get_viewport().sharpen_intensity = 0.5
	lastPos = squadron.global_transform.origin
	initAll(squadron)
	addAllFighters(squadron, fighterList1)
	addAllFlag(squadron)
	create_weapon_propfile()
	pc_count()
	Sentrience.memcontext_remove()
	var thread = Thread.new()
	if debug_threaded:
		thread.start(self, "gut_test")
	else: gut_test()
	if debug_threaded:
		while thread.is_alive():
			yield(get_tree(), "idle_frame")
		thread.wait_to_finish()
#	test_afbcfg()

func _exit_tree():
#	for f in fighterList1:
#		fighterList1[f].free()
#	print("Count: " + str(test_instance.count))
#	test_instance.free()
#	test_instance2.free()
	var trans := Sentrience.combatant_get_combined_transform(crid)
	print(trans)
	Sentrience.memcontext_flush(my_watcher)
	Sentrience.memcontext_remove()
#	Sentrience.flush_instances_pool()
#	Sentrience.free_rid(crid)
#	Sentrience.free_rid(srid)
#	Sentrience.free_all_instances()
#	var t1 := Sentrience.team_create()
#	var t2 := Sentrience.team_create()
#	var link := Sentrience.team_create_link(t1, t2)
	if not cf.is_legit():
		return
	while not cf.is_available():
		yield(Engine.get_main_loop(), "idle_frame")
	return

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
		fl[m]._vehicle_config.max_speed = 500.0
		fl[m]._vehicle_config.acceleration = 4.0
		fl[m]._vehicle_config.decceleration = -0.0
		fl[m]._vehicle_config.slowingTime = 2.0
#		fl[m]._vehicle_config.acceleration = 4.0
#		fl[m]._vehicle_config.decceleration = -32.0
#		fl[m]._vehicle_config.slowingTime = 0.405
		fl[m]._vehicle_config.turnRate = 0.03
		fl[m]._vehicle_config.maxTurnRate = 0.7
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
		flagList[m].visible = false
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

var is_firing := false
var volley_turn := 1
var delay_time := 0.02

func fire_stuff():
	if is_firing: return
	is_firing = true
	var volley_count := 0
	for f in fighterList1:
		fighterList1[f].get_fire_control().fire_once()
		volley_count += 1
		if volley_count >= volley_turn:
			volley_count = 0
			yield(Out.timer(delay_time), "timeout")
			continue
	is_firing = false

func graphics_switch():
	var curr: int = SettingsServer.current_graphics_preset
	var new_gp := 0
	if curr == SettingsServer.GRAPHICS_LOWEST:
		new_gp = SettingsServer.GRAPHICS_LOW
	elif curr == SettingsServer.GRAPHICS_LOW:
		new_gp = SettingsServer.GRAPHICS_MEDIUM
	elif curr == SettingsServer.GRAPHICS_MEDIUM:
		new_gp = SettingsServer.GRAPHICS_HIGH
	elif curr == SettingsServer.GRAPHICS_HIGH:
		new_gp = SettingsServer.GRAPHICS_HIGHEST
	elif curr == SettingsServer.GRAPHICS_HIGHEST:
		new_gp = SettingsServer.GRAPHICS_LOWEST
	else:
		return
	SettingsServer.current_graphics_preset = new_gp
#	print("Old preset: " + str(curr))
#	print("New preset: " + str(new_gp))

func _fire_test(_delta: float):
	if Input.is_action_just_pressed("ui_select"):
#		fire_stuff()
#		set_ownership(LevelManager.template)
#		var serialized := LevelManager.serialize_level(LevelManager.template)
#		print(serialized)
#		LevelManager.deserialize_level_debug(serialized)
#		var full_package := LevelManager.level2package(LevelManager.template)
#		LevelManager.set_level_defered(full_package)

		graphics_switch()
		pass

#onready var org_size := Vector2(1920, 1080)
var ssaa_scaling := 1.0
var borderless_fullscreen := false
var normal_windows_size := Vector2.ZERO
var normal_windows_pos  := Vector2.ZERO

onready var mesh := $TestMesh
onready var mesh2 := $TestMesh2

func balls():
	var pos: Vector3 = Vector3.ZERO
#	var x_axis := 0.0
#	var y_axis := 0.0
#	var z_axis := 0.0
	var x_axis := Vector3()
	var y_axis := Vector3()
	var z_axis := Vector3()
	var general_basis: Basis
	for f in fighterList1:
		var fighter: Spatial = fighterList1[f]
		pos += fighter.global_transform.origin
		x_axis += fighter.global_transform.basis.x
		y_axis += fighter.global_transform.basis.y
		z_axis += fighter.global_transform.basis.z
#		x_axis += fighter.global_transform.basis.get_euler().x
#		y_axis += fighter.global_transform.basis.get_euler().y
#		z_axis += fighter.global_transform.basis.get_euler().z
	pos /= fighterList1.size()
	x_axis = x_axis.normalized()
	y_axis = y_axis.normalized()
	z_axis = z_axis.normalized()
	general_basis = Basis(x_axis, y_axis, z_axis)
#	x_axis /= fighterList1.size();
#	y_axis /= fighterList1.size();
#	z_axis /= fighterList1.size();
#	var general_quat := Quat(Vector3(x_axis, y_axis, z_axis))
#	general_basis = Basis(general_quat)
	var new_transform := Transform(general_basis, pos)
	mesh.global_transform = new_transform
	mesh2.global_transform = new_transform
	mesh.scale = Vector3(5.0, 5.0, 5.0)
	mesh2.scale = Vector3(5.0, 5.0, 5.0)
	mesh2.global_translate(-mesh2.global_transform.basis.z * 50.0)

func _process(delta):
	loggit()
	dT = delta

func _physics_process(_delta):
	pcalls_count += 1

onready var di := $DebugInfo

static func int_to_gp(gp: int) -> String:
	var re := ""
	match gp:
		SettingsServer.GRAPHICS_CUSTOM:			re = "GRAPHICS_CUSTOM"
		SettingsServer.GRAPHICS_LOWEST:			re = "GRAPHICS_LOWEST"
		SettingsServer.GRAPHICS_LOW:			re = "GRAPHICS_LOW"
		SettingsServer.GRAPHICS_MEDIUM:			re = "GRAPHICS_MEDIUM"
		SettingsServer.GRAPHICS_HIGH:			re = "GRAPHICS_HIGH"
		SettingsServer.GRAPHICS_HIGHEST:		re = "GRAPHICS_HIGHEST"
	return re

static func int_to_dp(dp: int) -> String:
	var re := ""
	match dp:
		SettingsServer.WINDOWED:				re = "WINDOWED"
		SettingsServer.FULLSCREEN:				re = "FULLSCREEN"
		SettingsServer.BORDERLESS_FULLSCREEN:	re = "BORDERLESS_FULLSCREEN"
	return re

func loggit():
	di.table["Sentrience instances"] = String(Sentrience.get_instances_count())
	di.table["Sentrience memory usage"] = Sentrience.get_memory_usage_humanized()
	di.table["Debug loop"] = String(debug_loop_stage) + "/" + String(debug_loop_count)
	di.table["Static memory"] = String().humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC_MAX))
	di.table["Dynamic memory"] = String().humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC_MAX))
	di.table["Quality"] = String(SettingsServer.current_graphics_preset)
	di.table["Window mode"] = String(SettingsServer.current_display_preset)
	di.table["SSAA level"] = String(SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL))
	return
	var l_loc: Vector3
	var fighter_loc: Vector3 = fighterList1["P0"].global_transform.origin
	var angle := 0.0
	if is_instance_valid(launcher):
		l_loc = fighter_loc.direction_to(launcher.global_transform.origin)
		var f_loc: Vector3 = -fighterList1["P0"].global_transform.basis.z
		angle = f_loc.angle_to(l_loc)
	var curr_gp: int = SettingsServer.current_graphics_preset
	var curr_dp: int = SettingsServer.current_display_preset
	di.table = {
		"debug_build": str(OS.is_debug_build()),
		"processor_name": OS.get_processor_name(),
		"processor_count": OS.get_processor_count(),
		"graphics_device_name": VisualServer.get_video_adapter_name(),
		"graphics_device_vendor": VisualServer.get_video_adapter_vendor(),
		"memory_static_max": String().\
			humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)),
		"memory_dynamic_max": String().\
			humanize_size(Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX)),
		"graphics_preset": int_to_gp(curr_gp),
		"display_preset": int_to_dp(curr_dp),
		"res_preset_raw": SettingsServer.current_resolution_preset,
		"current_resolution": SettingsServer\
			.rs_to_vec2(SettingsServer.current_resolution_preset),
		"actual_resolution": get_viewport().size,
		"window_size": OS.window_size,
		"default_res": SettingsServer.rs_to_vec2(SettingsServer.RES_DEFAULT),
		"ssaa": SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL),
		"ips": Engine.iterations_per_second,
		"delta": dT,
		"is_moving_1": (fighterList1["P0"]).isMoving,
		"is_moving_2": (fighterList1["P1"]).isMoving,
		"physics_calls": physics_calls,
		"fullscreen": OS.window_fullscreen,
		"borderless_fullscreen": OS.window_borderless,
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
		"turn_timer": (fighterList1["P0"] \
			as NAFB_Standalone).pda.get_state_by_name("NAFBSS_Steer").turn_timer,
#		"speed_loss": fighterList1["P0"].realSpeedLoss,
		"missiles_left": weapon_handler.reserve,
		"ssaa_scaling": ssaa_scaling,
	}

func db_1_handler(_event: InputEvent):
	if Input.is_action_just_pressed("db_1"):
		var curr: int = SettingsServer.current_display_preset
		if curr == SettingsServer.WINDOWED:
			curr = SettingsServer.FULLSCREEN
		elif curr == SettingsServer.FULLSCREEN:
			curr = SettingsServer.BORDERLESS_FULLSCREEN
		else:
			curr = SettingsServer.WINDOWED
		SettingsServer.current_display_preset = curr

#		borderless_fullscreen = not borderless_fullscreen
#		if borderless_fullscreen:
#			normal_windows_size = OS.window_size
#			normal_windows_pos  = OS.window_position
#		OS.window_fullscreen = borderless_fullscreen
#		OS.window_borderless = borderless_fullscreen
#		OS.window_maximized = borderless_fullscreen
#		if not borderless_fullscreen:
#			OS.window_size = normal_windows_size
#			OS.window_position = normal_windows_pos

func db_2_handler(_event: InputEvent):
	if Input.is_action_just_pressed("db_2"):
		graphics_switch()

func db_3_handler(_event: InputEvent):
	if Input.is_action_just_pressed("db_3"):
		var curr_ssaa: float = \
			SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL)
		curr_ssaa = wrapf(curr_ssaa + 0.1, 0.7, 2.0)
		SettingsServer.set_graphics_setting(SettingsServer.SSAA_LEVEL, curr_ssaa)

func test_fire_handler(_event: InputEvent):
	if Input.is_action_just_pressed("test_fire"):
		fire_stuff()

const FORMATION_ELEVATION := 300.0

func _input(levent):
	test_fire_handler(levent)
	db_1_handler(levent)
	db_2_handler(levent)
	db_3_handler(levent)
	if not levent.is_class("InputEventMouseButton"): return
	if not levent.button_index == BUTTON_LEFT: return
	if not levent.pressed: return
	var cam = get_viewport().get_camera()
	var from: Vector3 = cam.project_ray_origin(levent.position)
	var to: Vector3 = from + cam.project_ray_normal(levent.position) * 1000000.0
	var intersection := Vector3.ZERO
	if USE_PLANE_EQUATION:
		var plane_equation := GeometryMf.pe_create_pc(0, 1, 0, 0)
		var line_equation := GeometryMf.le_create_v(from, to)
		intersection = line_equation.intersect(plane_equation)
	else:
		var space_state = get_world().direct_space_state
		var result: Dictionary = space_state.intersect_ray(from, to)
		if result.has("position"):
			intersection = result["position"]
	if intersection != Vector3.ZERO:
		var des: Vector3 = intersection + Vector3(0.0, FORMATION_ELEVATION, 0.0)
		var oldPos: Vector3 = fighterList1["P0"].global_transform.origin
		mousePos = des
		#--------------------------------------------------------
		squadron.translation = des
		var dir = (des - oldPos).normalized()
		squadron.look_at(squadron.global_transform.origin + dir, Vector3.UP)
		relocateAllFlag(squadron)
		guideAllFighter(squadron)
