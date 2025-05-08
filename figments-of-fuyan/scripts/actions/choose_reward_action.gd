class_name ChooseRewardAction extends Action # Used for the boxes with cards in them

var items: Array # [FofGD]

@export var chosen_index: int
@export var item_datas: Array

@export var auto_clear: bool
@export var reward_type: RewardType

enum RewardType {CARDS, MINIBOSS, BOSS}

func _init(_items: Array = [], _reward_type := RewardType.CARDS, _auto_clear: bool = true) -> void:
	super()
	items = _items
	reward_type = _reward_type
	auto_clear = _auto_clear
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var item: FofGD = items[chosen_index]
	
	for _item: FofGD in items:
		if _item != item: _item.onClear()
	
	items = []
	
	if item is CardGD:
		onPushAction(AddToDeckAction.new(item))
	elif item is BoonGD:
		onPushAction(AddBoonAction.new(item.info.id, item.getAscended()))

func onItemChosen(item: FofGD) -> void:
	chosen_index = items.find(item)

func onSave() -> void:
	super()
	item_datas = items.map(func(x: FofGD): return x.onSave())

func onLoad() -> void:
	super()
	items = []
	for saved_data: SavedData in item_datas:
		var item: FofGD = SavedData.onLoadModel(saved_data, Game.getLevel())
		items.append(item)
	
func getItems() -> Array:
	return items
