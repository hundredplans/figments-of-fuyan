extends Node3D

var Tile: TileGD
func _ready() -> void:
	for child in get_children():
		child.visible = false

func onCreatePastPath(rots: Array, nums: Array) -> void:
	position.y += (0.9 if Tile.tile.type == 1 else 0.3)
	for i in range(rots.size()):
		var section: Node3D = get_node(str(rots[i]))
		section.visible = true
		var label_3d: Label3D = section.get_node("Label3D")
		if label_3d.text.is_empty(): label_3d.text = str(nums[i])
		else: label_3d.text += ", " + str(nums[i])
