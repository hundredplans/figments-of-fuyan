class_name RevealAction extends Action

var GameObject: GameObjectGD
var Revealer: FofGD
var state: bool

func _init(_GameObject: GameObjectGD = null, _Revealer: FofGD = null, _state: bool = true) -> void:
	super()
	GameObject = _GameObject
	Revealer = _Revealer
	state = _state
	
func onPostAction() -> void:
	var visibles: Array = GameObject.getVisibleGroup()
	for _GameObject in visibles: # Ignores Cards unless they themself are revealed
		if !(_GameObject is CardGD and GameObject != _GameObject): _GameObject.onRevealed(state)
	
	onPushAction(LevelVisibleAction.new(state, visibles))
	
