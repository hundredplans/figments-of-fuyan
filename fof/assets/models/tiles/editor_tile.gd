extends Node

var info: Dictionary = {
}

func load_tile(id: int, _info: Array) -> void:
	var tile: Node3D = load("res://assets/models/tiles/" + Helper.id_to_tile(id) + ".glb").instantiate()
	add_child(tile)
	tile.name = "Tile"
	info.tid = id
	info.position = _info[0]


func _on_detect_mouse_mouse_entered():
	print(info.position)
