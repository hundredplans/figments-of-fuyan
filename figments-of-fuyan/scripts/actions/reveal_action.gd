class_name RevealAction extends Action

var GameObject: GameObjectGD
var Revealer: GameObjectGD

func _init(_GameObject: GameObjectGD = null, _Revealer: GameObjectGD = null) -> void:
	super()
	GameObject = _GameObject
	Revealer = _Revealer
	
func onPostAction() -> void:
	var visibles: Array = GameObject.getVisibleGroup()
	for _GameObject in visibles: # Ignores Cards unless they themself are revealed
		if !(_GameObject is CardGD and GameObject != _GameObject): _GameObject.onRevealed()
	
	onPushAction(LevelVisibleAction.new(true, visibles))
	
