extends Spatial

const self_destruct := preload("res://addons/utils/self_destruct.gd")
const explosion := preload("res://test_particles/RealExplosion1.tscn")
const explosion2 := preload("res://explosion2/ForwardExplosion.tscn")

onready var exhaust := $Trail/EngineExhaust
onready var afterburner: Particles = $Trail/EngineExhaust/JetPlume
onready var smoke: Particles = $Trail/EngineExhaust/SmokeExhaust

var speed_limit_percent := 0.9
var guide: WeaponGuidance = null

func arm_launched(guidance: WeaponGuidance):
	if guidance._armed or is_instance_valid(guide):
		return
	elif guidance is HomingGuidance:
		guide = guidance
		var vtol = guidance.vtol
		var turnRate = vtol._vehicle_config.turnRate
		var maxTurnRate = vtol._vehicle_config.maxTurnRate
		var maxSpeed = vtol._vehicle_config.maxSpeed
		vtol._vehicle_config.turnRate = 0.0
		vtol._vehicle_config.maxTurnRate = 0.0
		vtol._vehicle_config.maxSpeed = vtol.inheritedSpeed\
			* speed_limit_percent
		vtol.enableGravity = true
		afterburner.emitting = false
		smoke.emitting = false
		yield(get_tree().create_timer(guidance._arm_time), "timeout")
		guidance._armed = true
		guidance.emit_signal("__armmament_armed", guidance)
		vtol.enableGravity = false
		vtol._vehicle_config.turnRate = turnRate
		vtol._vehicle_config.maxTurnRate = maxTurnRate
		vtol._vehicle_config.maxSpeed = maxSpeed
		afterburner.emitting = true
		smoke.emitting = true

func arm_arrived(_guidance: WeaponGuidance):
	var current_scene := get_tree().current_scene
	var particle_parents: Node = exhaust.get_parent()
	var loc = exhaust.global_transform.origin
	var sd := self_destruct.new()
	
	sd.objects.append(exhaust)
	particle_parents.remove_child(exhaust)
	current_scene.add_child(exhaust)
	exhaust.translation = loc
	afterburner.emitting = false
	smoke.emitting = false
	
#	var ex := explosion.instance()
	var ex := explosion2.instance()
	current_scene.add_child(ex)
	ex.translation = loc
	ex.look_at(ex.global_transform.origin - \
		_guidance._projectile.global_transform.basis.z, Vector3.UP)
	
	ex.play()
	sd.destruct(smoke.lifetime, get_tree())

func _on_WarheadCollider_area_entered(_area):
	if not is_instance_valid(guide):
		return
	elif not guide._armed:
		# WARNING: EXPLOITABLE
		return
	guide._finalize()
