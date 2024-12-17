class_name FinishAwakenAction extends Action
# Marker used to signify when all the processes after awakening finish

var Card: CardGD
func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass

func getDelay() -> float:
	return super()
