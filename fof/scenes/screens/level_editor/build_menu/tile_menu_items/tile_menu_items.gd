extends Node
var parent: Control
func _ready() -> void:
	for child in get_children():
		if child.name == "Paste" and parent.tiles.size() > 1: child.disabled = true
		elif child is Button: child.pressed.connect(func(): parent.parent[child.name.to_lower()].emit(parent.tiles))
		elif child is Control: child.item_selected.connect(
			func(i: int): parent.parent[child.name.to_lower()].emit(i, parent.tiles))
	
	load_independent()

func load_independent() -> void:
	load_spawns()
	
func load_spawns():
	if parent.item_name == "Obj":
		$Spawn.visible = (parent.tiles.size() == 1 and parent.tiles[0].info.obj.id in [1, 3])

func on_update_tile_menu() -> void:
	for child in get_children():
		if child.name == "Paste": child.disabled = parent.tiles.size() > 1
	load_independent()
