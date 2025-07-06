class_name Reward extends Resource

var item: FofGD

@export var taken: bool

@export var item_data: SavedData

func _init(_item: FofGD = null, _taken: bool = false) -> void:
	item = _item
	taken = _taken

func onSave() -> void:
	item_data = item.onSave()
	
func onLoad(parent: FofGD) -> void:
	item = SavedData.onLoadModel(item_data, parent)

func isTaken() -> bool:
	return taken

func setTaken(state: bool) -> void:
	taken = state
	
func getRewardType() -> GDScript:
	return item.get_script()
	
func getItem() -> FofGD:
	return item
