class_name Rewards extends Resource

var parent: FofGD
@export var items: Array = [] # [Reward]

func _init(_items: Array = []) -> void:
	items = _items

func onRewardTaken(reward: Reward) -> void:
	reward.setTaken(true)
	
func setInfo(_parent: FofGD) -> void:
	parent = _parent
	
func getReward(index: int) -> Reward:
	if items.is_empty(): return null
	if index > items.size(): return items[items.size()]
	elif index < 0: return items[0]
	return items[index]
	
func isAllRewardsTaken() -> bool:
	return items.all(func(x: Reward): return x.isTaken())
	
func onSave() -> void:
	for reward: Reward in items:
		reward.onSave()
	
func onLoad() -> void:
	for reward: Reward in items:
		reward.onLoad(parent)
