extends MapNodeGD

var campfire_reward_taken: Array = [false, false, false, false]
	
func onSave() -> SavedDataMapNode:
	ability_save["campfire_reward_taken"] = campfire_reward_taken
	return super()
