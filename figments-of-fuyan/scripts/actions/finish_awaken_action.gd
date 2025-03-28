class_name FinishAwakenAction extends Action
# Marker used to signify when all the processes after awakening finish

var Card: CardGD
var override_spectate: bool
func _init(_Card: CardGD = null, _override_spectate: bool = false) -> void:
	super()
	Card = _Card
	override_spectate = _override_spectate
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
