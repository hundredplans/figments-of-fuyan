class_name CameraChangeAction extends Action

var SpectateObject: GameObjectGD
func _init(_SpectateObject: GameObjectGD = null) -> void:
	super()
	SpectateObject = _SpectateObject
	
func onPreAction() -> void:
	if SpectateObject is GameObjectGD and !SpectateObject.isLevelVisible():
		onFailAction()
		
func onPostAction() -> void:
	Game.getLevel().onCameraChange(self)
	
func getLogInfo() -> Array:
	return ["SpectateObject: " + SpectateObject.info.name if SpectateObject != null else "Freelook"]
