extends GutTest

var erasure_test := true

var trans: Transform
var rid: RID

func test_general():
	var watch := Sentrience.memcontext_create()
	var combatant := Sentrience.combatant_create()
	var combatant2 := Sentrience.combatant_create()
	var squad := Sentrience.squad_create()
	var fake_squad := Sentrience.squad_create()
	var team := Sentrience.team_create()
	var simulation := Sentrience.simulation_create()
	var all_instances := []
	if erasure_test:
		all_instances = [combatant, combatant2, squad, fake_squad, team, simulation]
	assert_ne(combatant.get_id(), 0)
	assert_ne(combatant2.get_id(), 0)
	assert_ne(squad.get_id(), 0)
	assert_ne(team.get_id(), 0)
	assert_ne(simulation.get_id(), 0)
	assert_eq(Sentrience.combatant_assert(combatant), true)
	assert_eq(Sentrience.combatant_assert(combatant2), true)
	assert_eq(Sentrience.squad_assert(squad), true)
	assert_eq(Sentrience.simulation_assert(simulation), true)
	assert_eq(Sentrience.team_assert(team), true)

	Sentrience.simulation_set_active(simulation, true)
	assert_eq(Sentrience.simulation_is_active(simulation), true)
	Sentrience.combatant_set_simulation(combatant, simulation)
	Sentrience.squad_set_simulation(squad, simulation)
	Sentrience.team_set_simulation(team, simulation)
	Sentrience.squad_add_combatant(squad, combatant)
#	Sentrience.squad_add_combatant(squad, combatant2)
	Sentrience.team_add_squad(team, squad)
	assert_eq(Sentrience.combatant_is_squad(combatant, squad), true)
	assert_ne(Sentrience.combatant_is_squad(combatant2, squad), true)
	assert_ne(Sentrience.combatant_is_squad(combatant2, fake_squad), true)
	assert_ne(Sentrience.squad_is_team(fake_squad, team), true)
	assert_eq(Sentrience.squad_is_team(squad, team), true)
	assert_eq(Sentrience.combatant_is_team(combatant, team), true)
	assert_eq(Sentrience.squad_has_combatant(squad, combatant), true)
	Sentrience.squad_remove_combatant(squad, combatant)
	assert_eq(Sentrience.squad_has_combatant(squad, combatant), false)
	Sentrience.squad_remove_combatant(squad, combatant)
	assert_eq(Sentrience.squad_has_combatant(squad, combatant), false)
	Sentrience.squad_remove_combatant(squad, combatant2)
	assert_eq(Sentrience.squad_has_combatant(squad, combatant), false)
	assert_eq(Sentrience.squad_has_combatant(squad, combatant2), false)
	assert_ne(Sentrience.combatant_get_simulation(combatant).get_id(), 0)
	assert_ne(Sentrience.squad_get_simulation(squad).get_id(), 0)

	Sentrience.team_remove_squad(team, squad)
	assert_ne(Sentrience.squad_is_team(squad, team), true)
	Sentrience.squad_remove_combatant(squad, combatant)
	assert_ne(Sentrience.combatant_is_squad(combatant, squad), true)
	Sentrience.memcontext_flush(watch)

func test_team_affiliation():
	# Initialization
	var watch := Sentrience.memcontext_create()
	var simulation        := Sentrience.simulation_create()
	var combatant_1_a_i   := Sentrience.combatant_create()
	var combatant_2_a_i   := Sentrience.combatant_create()
	var combatant_1_b_i   := Sentrience.combatant_create()
	var combatant_1_a_ii  := Sentrience.combatant_create()
	var squad_a_i         := Sentrience.squad_create()
	var squad_b_i         := Sentrience.squad_create()
	var squad_a_ii        := Sentrience.squad_create()
	var team_i            := Sentrience.team_create()
	var team_ii           := Sentrience.team_create()
	# Simulation Assignment
	Sentrience.combatant_set_simulation(combatant_1_a_i, simulation)
	Sentrience.combatant_set_simulation(combatant_2_a_i, simulation)
	Sentrience.combatant_set_simulation(combatant_1_b_i, simulation)
	Sentrience.combatant_set_simulation(combatant_1_a_ii, simulation)
	Sentrience.squad_set_simulation(squad_a_i, simulation)
	Sentrience.squad_set_simulation(squad_b_i, simulation)
	Sentrience.squad_set_simulation(squad_a_ii, simulation)
	Sentrience.team_set_simulation(team_i, simulation)
	Sentrience.team_set_simulation(team_ii, simulation)
	# General Assignment
	Sentrience.squad_add_combatant(squad_a_i, combatant_1_a_i)
	Sentrience.squad_add_combatant(squad_a_i, combatant_2_a_i)
	Sentrience.squad_add_combatant(squad_b_i, combatant_1_b_i)
	Sentrience.squad_add_combatant(squad_a_ii, combatant_1_a_ii)
	Sentrience.team_add_squad(team_i, squad_a_i)
	Sentrience.team_add_squad(team_i, squad_b_i)
	Sentrience.team_add_squad(team_ii, squad_a_ii)
	# Activation
	Sentrience.simulation_set_active(simulation, true)
	# Linkage
	Sentrience.team_create_link_bilateral(team_i, team_ii)
	var team_link_i_ii := Sentrience.team_get_link(team_i, team_ii)
	var team_link_ii_i := Sentrience.team_get_link(team_ii, team_i)
	assert_ne(team_link_i_ii == null, true)
	assert_ne(team_link_ii_i == null, true)
	if team_link_i_ii == null or team_link_ii_i == null: return
	# Assertion (General)
	assert_eq(Sentrience.simulation_count_combatant(simulation), 4)
	assert_eq(Sentrience.simulation_count_squad(simulation), 3)
	assert_eq(Sentrience.simulation_count_team(simulation), 2)
	assert_eq(Sentrience.squad_count_combatant(squad_a_i), 2)
	assert_eq(Sentrience.squad_count_combatant(squad_a_ii), 1)
	assert_eq(Sentrience.squad_count_combatant(squad_b_i), 1)
	assert_eq(Sentrience.team_count_squad(team_i), 2)
	assert_eq(Sentrience.team_count_squad(team_ii), 1)
	# Assertion (Hostiles)
	team_link_i_ii.attributes = 0 + RCSUnilateralTeamsBind.ITA_Engagable
	team_link_ii_i.attributes = 0 + RCSUnilateralTeamsBind.ITA_Engagable
	assert_eq(Sentrience.combatant_engagable(combatant_1_a_i, combatant_1_a_ii), true)
	assert_eq(Sentrience.combatant_engagable(combatant_1_b_i, combatant_1_a_ii), true)
	assert_eq(Sentrience.combatant_engagable(combatant_2_a_i, combatant_1_a_ii), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_a_i, combatant_2_a_i), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_a_i, combatant_1_b_i), true)
	assert_eq(Sentrience.combatant_engagable(combatant_2_a_i, combatant_1_a_ii), true)
	assert_eq(Sentrience.combatant_engagable(combatant_1_b_i, combatant_1_a_ii), true)
	# Assertion (Allies)
	team_link_i_ii.attributes = 0
	team_link_ii_i.attributes = 0
	assert_ne(Sentrience.combatant_engagable(combatant_1_a_i, combatant_1_a_ii), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_b_i, combatant_1_a_ii), true)
	assert_ne(Sentrience.combatant_engagable(combatant_2_a_i, combatant_1_a_ii), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_a_i, combatant_2_a_i), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_a_i, combatant_1_b_i), true)
	assert_ne(Sentrience.combatant_engagable(combatant_2_a_i, combatant_1_a_ii), true)
	assert_ne(Sentrience.combatant_engagable(combatant_1_b_i, combatant_1_a_ii), true)
	# Assertion (Neutrals)
	assert_eq(Sentrience.simulation_count_all_instances(simulation), 9)
	Sentrience.memcontext_flush(watch)

func test_engagement():
	var watch := Sentrience.memcontext_create()
	var simulation := Sentrience.simulation_create()
	Sentrience.simulation_set_active(simulation, true)
	assert_eq(Sentrience.simulation_is_active(simulation), true)
	assert_eq(Sentrience.simulation_get_all_engagements(simulation), [])
	assert_eq(Sentrience.simulation_count_engagement(simulation), 0)
	Sentrience.memcontext_flush(watch)

func _enter_tree():
	Sentrience.set_active(true)
#	var watcher := Sentrience.memcontext_create()

func _exit_tree():
#	Sentrience.flush_instances_pool()
#	var a := 0
#	a = 2
#	Sentrience.free_all_instances()
	pass
