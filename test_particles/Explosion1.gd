extends Spatial

const self_destruct := preload("res://addons/utils/self_destruct.gd")

const explosions_flipbook := [
	preload("res://test_particles/Explosion00_5x5.png"),
	preload("res://test_particles/Explosion01_5x5.png"),
	preload("res://test_particles/Explosion01-light_5x5.png"),
]

var child: MeshInstance = null
var player: AnimationPlayer = null
var mat: ShaderMaterial = null

func _ready():
	child = get_child(0)
	player = child.get_node("anim")
	mat = child.get_active_material(0)
	randomize()

func play():
	var anim := player.get_animation("explosion")
	player.play("explosion")
	var sd := self_destruct.new()
	sd.objects.append(self)
	var length: float = anim.length
	sd.destruct(length, get_tree())
