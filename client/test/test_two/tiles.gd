extends Node3D

var tile_positions: Array = [[], [], [], [], []]

func _ready():
	for child in get_children():
		var x: int = child.get_position().x
		var tile_position_index: float = (x / 2) + 2
		tile_positions[tile_position_index].append(child)
		
	for unsorted_tiles in tile_positions:
		unsorted_tiles.sort_custom(func(a, b): return a.get_position().z < b.get_position().z)

	if "a" in "bad":
		print("hi")
		
#	"u", "t", "w", "s", "p", "c"
