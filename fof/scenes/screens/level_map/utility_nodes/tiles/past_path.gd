extends Node3D

var Tile: TileGD

func _ready() -> void:
	for child in get_children():
		child.visible = false

func onCreatePastPath(rot: int, nums: Array) -> void:
	position.y += 0.3
	if Tile.tile.type == 1:
		position.y += 0.6
		
	if Tile.tile.type in [0, 1]:
		onCreateTilePastPath(rot, nums)

func onCreateTilePastPath(rot: int, nums: Array) -> void:
	var section: Node3D = get_node(str(rot))
	section.visible = true
	section.get_node("Label3D").text = str(nums).left(-1).right(-1)
