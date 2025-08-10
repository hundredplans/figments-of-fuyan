extends Control

func _ready() -> void:
	var parent := Node3D.new()
	add_child(parent)
	for id: int in range(2, 5):
		var Boon: BoonGD = SavedData.onLoadModel(SavedDataBoon.new(id, true), parent)
		%BoonBox.onAddBoon(Boon)

	for BoonIcon: TbcUI in %BoonBox.get_children():
		BoonIcon.setHoverable(true)	
		BoonIcon.setDraggable(true)
