class_name LevelGD extends Node3D

var info: LevelInfoGD
var timeout: int

func onClear() -> void:
	queue_free()

func onLoad(data: SavedData, parent: Node3D) -> LevelGD:
	info = data.getBaseInfo()
	add_to_group("Levels")
	parent.add_child(self)
	return self

func onSave() -> SavedDataLevel:
	return SavedDataLevel.new(info.id)
