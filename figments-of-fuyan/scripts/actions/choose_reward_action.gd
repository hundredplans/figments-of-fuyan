class_name ChooseRewardAction extends Action # Used for the boxes with cards in them

var items: Array # [FofGD]

@export var chosen_index: int
@export var items_public_ids: Array[int]

@export var auto_clear: bool

func _init(_items: Array = [], _auto_clear: bool = true) -> void:
	super()
	items = _items
	auto_clear = _auto_clear
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var item: FofGD = items[chosen_index]
	
	for _item: FofGD in items:
		if _item != item: _item.onClear()
	
	items = []
	
	if item is CardGD:
		onPushAction(AddToDeckAction.new(item, AddToDeckAction.ADD_TYPES.SHUFFLE))

func onSave() -> void:
	super()
	items_public_ids = items.map(func(x: FofGD): return x.public_id)

func onLoad() -> void:
	super()
	items = items_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func getItems() -> Array:
	return items
