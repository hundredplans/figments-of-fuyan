class_name ChangeAttacksAction extends Action

var GameObject: GameObjectGD
var attacks: int

func _init(_GameObject: GameObjectGD = null, _attacks: int = 0) -> void:
	super()
	GameObject = _GameObject
	attacks = _attacks

func onPostAction() -> void:
	GameObject.setAttacks(attacks)
