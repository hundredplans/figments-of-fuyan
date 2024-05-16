extends Node3D

var Tile: TileGD
func _ready() -> void:
	for child in get_children():
		child.visible = false

func onCreatePastPath(rots: Array, nums: Array) -> void:
	rotation_degrees.y += 60 * Tile.tile.rotation
	for i in range(rots.size()):
		var rot: int = 0
		if ((Tile.tile.rotation + 3) % 5 == rots[i] or (rots[i] + 3) % 5 == Tile.tile.rotation): rot = 1
		var section: Node3D = get_node(str(rot))
		section.visible = true
		var label_3d: Label3D = section.get_node("Label3D")
		if label_3d.text.is_empty(): label_3d.text = str(nums[i])
		else: label_3d.text += ", " + str(nums[i])
