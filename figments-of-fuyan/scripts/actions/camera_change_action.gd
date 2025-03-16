class_name CameraChangeAction extends Action

var SpectateObject: GameObjectGD
func _init(_SpectateObject: GameObjectGD = null) -> void:
	super()
	SpectateObject = _SpectateObject
	
func onPreAction() -> void:
	if SpectateObject != null and !SpectateObject.isLevelVisible() or (SpectateObject is CardGD and !SpectateObject.isAlive()):
		onFailAction()
		
func onPostAction() -> void:
	Game.getLevel().onCameraChange(self)
	
func getLogInfo() -> Array:
	return ["SpectateObject: " + SpectateObject.info.name if SpectateObject != null else "Freelook"]
