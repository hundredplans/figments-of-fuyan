class_name StartLoadingScreenAction extends Action

var loading_type: Game.LoadingType
var area_id: int
var level_name: String
var progress: int
var curse_id: int

func _init(_loading_type := Game.LoadingType.LEVEL, _area_id: int = 0, _level_name: String = "", _progress: int = 0, _curse_id: int = 0) -> void:
	super()
	loading_type = _loading_type
	area_id = _area_id
	level_name = _level_name
	progress = _progress
	curse_id = _curse_id
	setFrameDelay(1)

func getAreaID() -> int: return area_id

func onPostAction() -> void:
	Game.getMain().onStartLoadingScreen(self)
	
func getLoadingType() -> Game.LoadingType:
	return loading_type
	
func getLevelName() -> String: return level_name
func getProgress() -> int: return progress
func getCurseID() -> int: return curse_id
