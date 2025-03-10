extends Node

func _ready() -> void:
	var love_coco: LevelInfo = load("res://resources/fof/levels/kokos_heights.tres")
	for data: SavedData in love_coco.data:
		data.coords.w += 10
		if data is SavedDataObject:
			data.position.y += 6
	ResourceSaver.save(love_coco)
