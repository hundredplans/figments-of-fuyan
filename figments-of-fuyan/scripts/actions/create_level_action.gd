class_name CreateLevelAction extends Action

var level_data: SavedDataLevel
var progress: int
func _init(_level_data: SavedDataLevel = null) -> void:
	super()
	level_data = _level_data
	progress = Game.getArea().getProgress()
	
func onPreAction() -> void:
	level_data.max_energy = Game.getSaveFile().max_energy
	level_data.energy = level_data.max_energy
	
func onPostAction() -> void:
	onPushAction(EndLoadingScreenAction.new())
	
func getLevelData() -> SavedDataLevel:
	return level_data
