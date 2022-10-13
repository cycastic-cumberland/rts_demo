extends MunitionController

const SPEED_LIMIT_PERCENTILE := 0.9

func premature_detonation_handler(area):
	if guidance._armed:
		.premature_detonation_handler(area)
	else:
		Utilities.TrialTools.try_set(warhead_ref, "wc_ref.monitoring", false, true)
		guidance.vtol.trackingTarget = null
		guidance.vtol.isMoving = false
		detonated = true
		guidance._clean()

func _start():
	if not guidance is HomingGuidance:
		return
	var vtol = guidance.vtol
	var turnRate = vtol._vehicle_config.turnRate
	var maxTurnRate = vtol._vehicle_config.maxTurnRate
	var maxSpeed = vtol._vehicle_config.maxSpeed
	# Prevent the deliver from rotating
	vtol._vehicle_config.turnRate = 0.0
	vtol._vehicle_config.maxTurnRate = 0.0
	# Simulate drag by making the deliver slower than the carrier
	vtol._vehicle_config.maxSpeed = vtol.inheritedSpeed \
		* SPEED_LIMIT_PERCENTILE
	vtol.enableGravity = true
	set_particle_emit(false)
	yield(Out.timer(guidance._arm_time), "timeout")
	if detonated:
		deliver.queue_free()
		return
	vtol.enableGravity = false
	set_particle_emit(true)
	vtol._vehicle_config.turnRate = turnRate
	vtol._vehicle_config.maxTurnRate = maxTurnRate
	vtol._vehicle_config.maxSpeed = maxSpeed
	._start()
