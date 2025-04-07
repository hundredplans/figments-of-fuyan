class_name Rewards extends Resource

var parent: FofGD
@export var items: Array = [] # [Reward]

func _init(_items: Array = []) -> void:
	items = _items

func onRewardTaken(reward: Reward) -> void:
	reward.setTaken(true)
	
func setInfo(_parent: FofGD) -> void:
	parent = _parent
	
func onSave() -> void:
	for reward: Reward in items:
		reward.onSave()
	
func onLoad() -> void:
	for reward: Reward in items:
		reward.onLoad(parent)
