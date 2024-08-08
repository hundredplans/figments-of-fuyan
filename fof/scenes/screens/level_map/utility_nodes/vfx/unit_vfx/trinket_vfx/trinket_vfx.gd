extends UnitVFXBase

@onready var Sphere: Node3D = $Sphere
@export var ROTATION_SPEED: float = 100

const ID_TO_MATERIAL: Dictionary = {
	0: "flat_red",
	1: "flat_grey",
	2: "flat_blue",
	3: "flat_purple",
	4: "flat_green"
}

func setInfo(id: int) -> void:
	var mat: StandardMaterial3D = load("res://scenes/screens/level_map/utility_nodes/vfx/unit_vfx/trinket_vfx/materials/" + ID_TO_MATERIAL[id] + ".tres")
	Sphere.set_surface_override_material(0, mat)

func _process(delta: float) -> void:
	rotation_degrees.y += 100 * delta
