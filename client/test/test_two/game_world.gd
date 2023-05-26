extends Node3D
@onready var tiles = $tiles

func _ready():
#	for tile in tiles.get_children():
#		tile.tile_inputA.connect(on_tile_inputA)
#		tile.tile_inputB.connect(on_tile_inputB)
	pass

func on_tile_inputA(tile: Node3D):
	var _position := tile_to_position(tile)
	
func on_tile_inputB(tile: Node3D):
	pass

func tile_to_position(tile: Node3D) -> Vector2:
	var t: Array = tiles.tile_positions
	for x in t.size():
		var y: int = t.find(tile)
		if y >= 0:
			return Vector2(x + 1, y + 1)
	return Vector2.ZERO
