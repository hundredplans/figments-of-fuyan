extends Node

func _ready() -> void:
	var arr: Array = []
	#print(Color(0.086, 0.549, 0.878).hex())
	print(arr.all(func(x: int): return x == 0))
	print(arr.any(func(x: int): return x == 0))
	pass
	#var love_coco: LevelInfo = load("res://resources/fof/levels/kokos_heights.tres")
	#for data: SavedData in love_coco.data:
		#data.coords.w += 10
		#if data is SavedDataObject:
			#data.position.y += 6
	#ResourceSaver.save(love_coco)
