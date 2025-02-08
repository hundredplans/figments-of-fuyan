class_name CameraChangeAction extends Action

var SpectateObject: GameObjectGD
func _init(_SpectateObject: GameObjectGD = null) -> void:
	super()
	SpectateObject = _SpectateObject
	
func onPreAction() -> void:
	if SpectateObject is CardGD and !SpectateObject.isLevelVisible():
		onFailAction()
	
func getLogInfo() -> Array:
	return ["SpectateObject: " + SpectateObject.info.name if SpectateObject != null else "Freelook"]
