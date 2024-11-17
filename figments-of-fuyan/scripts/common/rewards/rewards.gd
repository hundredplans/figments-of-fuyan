class_name Rewards extends Resource

var parent: FofGD
@export var items: Array = []
@export var taken_items: Array = []
func _init(_items: Array = []) -> void:
	items = _items

func onRewardTaken(reward: Variant) -> void:
	if reward is CardGD:
		for item in items.filter(func(x: Variant): return x is Array and reward in x):
			items.erase(item)
			taken_items.append(item)
			return
			
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

func onSaveMap(x: Variant) -> Variant:
	if x is Array:
		return SavedData.onSaveGroup(x)
	return x.onSave()
	
func onLoadMap(x: Variant) -> Variant:
	if x is Array:
		return x.map(func(y: SavedDataCard): return SavedData.onLoadModel(y, parent))
	return SavedData.onLoadModel(x, parent)
