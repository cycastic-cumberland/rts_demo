extends Combatant

var no_hp := false

export(float, 10.0, 10000.0, 0.1) var HP := 100.0

func _init():
	_vehicle_config = CombatantConfiguration.new()
	_vehicle_config.hullProfile.connect("__out_of_hp", self, "oof")
	_vehicle_config.hullProfile.connect("__hp_updated", self, "hp_update")

func _ready():
	_vehicle_config.hullProfile.max_hp = HP
	_vehicle_config.hullProfile.current_hp = HP

func oof():
	no_hp = true
	Out.print_debug("Oopsie doopsie")
#	visible = false
	queue_free()

func hp_update(_hull, curr: float, amount: float):
	Out.print_debug("Current amount: {c}, delta: ({d})"\
		.format({"c": curr, "d": amount}))
