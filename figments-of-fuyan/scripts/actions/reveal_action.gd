class_name RevealAction extends Action

var Revealed: GameObjectGD
var revealed_datastore: RevealedDatastore

func _init(_Revealed: GameObjectGD = null, _revealed_datastore: RevealedDatastore = null) -> void:
	super()
	Revealed = _Revealed
	revealed_datastore = _revealed_datastore
	
func onPostAction() -> void:
	var visibles: Array = Revealed.getRevealVisibleGroup()
	for _GameObject in visibles: # Ignores Cards unless they themself are revealed
		_GameObject.onRevealed(revealed_datastore)
	onPushAction(VisionAction.new())
	
