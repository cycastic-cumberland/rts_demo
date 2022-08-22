extends Combatant

var no_hp := false

func _init():
	_vehicle_config = CombatantConfiguration.new()
	_vehicle_config.hullProfile.connect("__out_of_hp", self, "oof")
	_vehicle_config.hullProfile.connect("__hp_updated", self, "hp_update")

func oof():
	no_hp = true
	Out.print_debug("Oopsie doopsie")
	visible = false

func hp_update(_hull, curr: float, amount: float):
	Out.print_debug("Current amount: {c}, delta: ({d})"\
		.format({"c": curr, "d": amount}))
