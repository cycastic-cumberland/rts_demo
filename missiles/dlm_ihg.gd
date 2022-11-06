extends MunitionController

func premature_detonation_handler(area):
	if guidance._armed:
		.premature_detonation_handler(area)
	else:
		Utilities.TrialTools.try_set(warhead_ref, "wc_ref.monitoring", false, true)
		guidance._finalize()
		detonated = true

func _start():
#	return
#	if not guidance is HomingGuidance:
#		return
	var deliver: SimpleIntegratedMissilePerformer = guidance.embedded_system
	# Simulate drag by making the deliver slower than the carrier
	deliver.accelarator = false
	deliver.gravity = true
	deliver.allow_turn = false
	set_particle_emit(false)
	yield(Out.timer(guidance._arm_time), "timeout")
	if detonated:
		return
	set_particle_emit(true)
	deliver.accelarator = true
	deliver.gravity = false
	deliver.allow_turn = true
	._start()
