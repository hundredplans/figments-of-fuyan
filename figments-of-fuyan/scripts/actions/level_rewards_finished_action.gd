class_name LevelRewardsFinishedAction extends Action

var active_level_data: SavedDataLevel
func _init(_active_level_data: SavedDataLevel = null) -> void:
	super()
	active_level_data = _active_level_data
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass

func getActiveLevelData() -> SavedDataLevel:
	return active_level_data
