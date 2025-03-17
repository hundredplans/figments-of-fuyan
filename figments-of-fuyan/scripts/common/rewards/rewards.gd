class_name Rewards extends Resource

var parent: FofGD

@export var items: Array = []
@export var taken_items: Array = []

func _init(_items: Array = []) -> void:
	items = _items

func onRewardTaken(reward: Variant) -> void:
	items.erase(reward)
	taken_items.append(reward)
	
func setInfo(_parent: FofGD) -> void:
	parent = _parent
	
func onSave() -> void:
	items = items.map(onSaveMap)
	taken_items = taken_items.map(onSaveMap)
	
func onLoad() -> void:
	items = items.map(onLoadMap)
	taken_items = taken_items.map(onLoadMap)

func onSaveMap(x: FofGD) -> SavedData:
	return x.onSave()
	
func onLoadMap(x: SavedData) -> FofGD:
	return SavedData.onLoadModel(x, parent)
