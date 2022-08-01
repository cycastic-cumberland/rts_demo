extends Button

export(String) var wire_signal := ""

func _ready():
	if owner == null:
		return
	if not owner is PauseMenuUI:
		return
	setup()

func setup():
	if wire_signal.empty():
		return
	connect("pressed", owner, wire_signal)
