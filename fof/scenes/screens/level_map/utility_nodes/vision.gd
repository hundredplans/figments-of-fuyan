extends Node3D
var Tiles: TilesGD
var _Darkness: PackedScene = preload("res://scenes/screens/level_map/level_objects/darkness.glb")
var GameState: Node

func on_recalculate_vision() -> void:
	if false:
		on_clear_darkness()
		var spawn_tiles: Array = Tiles.on_is_type_get_tiles("Spawn", "obj")
		var tiles: Array = Tiles.outside_neighbours(spawn_tiles)
		
		var close_outside_tiles: Array = Tiles.from_center_concentric(GameState.level_info.level_size - 1)
		var outside_tiles: Array = Tiles.from_center_concentric(GameState.level_info.level_size)
		for tile in spawn_tiles: if tile in outside_tiles: outside_tiles.erase(tile)
		
		for tile in close_outside_tiles:
			for otile in outside_tiles:
				var rot: int = Tiles.neighbour_rotation(tile, otile, true)
				if rot >= 0:
					for n in range(11): 
						var Darkness: Node3D = _Darkness.instantiate()
						Darkness.position = Vector3(otile.global_position.x, (0.3) + 1.2 * n, otile.global_position.z)
						Darkness.rotation_degrees.y = rot * 60
						add_child(Darkness)
		
		for tile in tiles:
			for otile in spawn_tiles:
				var rot: int = Tiles.neighbour_rotation(tile, otile)
				if rot >= 0:
					for n in range(11): 
						var Darkness: Node3D = _Darkness.instantiate()
						Darkness.position = Vector3(otile.global_position.x, (0.3) + 1.2 * n, otile.global_position.z)
						Darkness.rotation_degrees.y = rot * 60
						add_child(Darkness)
						
		var diagonal_tiles: Array = Tiles.all_diagonals(Tiles.position_to_tile(Vector4(0,0,0,0)), GameState.level_info.level_size, outside_tiles)
		for tile in outside_tiles:
			for otile in diagonal_tiles:
				var rot: int = Tiles.neighbour_rotation(tile, otile, true)
				if rot >= 0:
					for n in range(11): 
						var Darkness: Node3D = _Darkness.instantiate()
						Darkness.position = Vector3(otile.global_position.x, (0.3) + 1.2 * n, otile.global_position.z)
						Darkness.rotation_degrees.y = rot * 60
						add_child(Darkness)

func on_clear_darkness() -> void:
	for child in get_children(): child.queue_free()
