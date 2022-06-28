extends Spatial

onready var car = $car
onready var wheels = [
	$car/VehicleWheel,
	$car/VehicleWheel2,
	$car/VehicleWheel3,
	$car/VehicleWheel4
]


func _physics_process(delta):
	car.engine_force = -1000.0
