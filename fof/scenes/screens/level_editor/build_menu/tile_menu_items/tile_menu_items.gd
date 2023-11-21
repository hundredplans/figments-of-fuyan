extends Node
var parent: Control
func _ready() -> void:
	for child in get_children():
		if child is Button: child.pressed.connect(func(): parent.parent[child.name.to_lower()].emit(parent.tiles))
		elif child is Control: child.item_selected.connect(
			func(i: int): parent.parent[child.name.to_lower()].emit(i, parent.tiles))

func load_independent() -> void:
	match parent.item_name:
		"Obj":
			$Spawn.visible = (parent.tiles.size() == 1 and parent.tiles[0].info.obj.id in [1, 3])
		"Wall":
			for child in [$Fill_Wall, $Tile_Wall, $Wall_Height]:
				child.visible = parent.tiles.any(func(x: Node3D): return x.info.wall.id > 0)

func on_update_tile_menu() -> void:
	load_independent()
	for child in get_children():
		if child.name == "Wall_Height":
			if parent.tiles.size() == 1 and parent.tiles[0].info.wall.id > 0:
				child.default = parent.tiles[0].info.wall.multi_tile.size()
				if child.default == 0 and parent.tiles[0].info.wall.tile_wall != 2: child.default = 1
				child.set_grabber_position(false)
