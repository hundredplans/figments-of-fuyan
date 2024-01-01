extends Node3D

var area_id: int = 0
func _ready():
	var area_map: Node3D = load("res://assets/base_game/areas/" + Helper.id_to_dict(area_id, "Area").bgfn + "/area_map.glb").instantiate()
	add_child(area_map)
