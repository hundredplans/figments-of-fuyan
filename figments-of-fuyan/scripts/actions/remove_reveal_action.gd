class_name RemoveRevealAction extends Action

var Revealed: GameObjectGD
var revealed_id: int

func _init(_Revealed: GameObjectGD = null, _revealed_id: int = 0) -> void:
	super()
	Revealed = _Revealed
	revealed_id = _revealed_id
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Revealed.onRemoveReveal(revealed_id)
	var visibles: Array = Revealed.getVisibleGroup()
	for _GameObject in visibles: # Ignores Cards unless they themself are revealed
		if !(_GameObject is CardGD and Revealed != _GameObject):
			_GameObject.onRemoveReveal(revealed_id)
		_GameObject.onUpdateLevelVisible()
