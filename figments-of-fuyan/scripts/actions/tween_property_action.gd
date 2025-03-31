class_name TweenPropertyAction extends Action

var GameObject: GameObjectGD
var duration: float
var property: String
var trans_type: Tween.TransitionType
var end_value: Variant
var custom_delay: float

func _init(_GameObject: GameObjectGD = null, _property: String = "position", _end_value: Variant = null, _duration: float = 0.0,\
	_trans_type := Tween.TransitionType.TRANS_SINE, _custom_delay: float = -1.0) -> void:
	super()
	GameObject = _GameObject
	duration = _duration
	property = _property
	trans_type = _trans_type
	end_value = _end_value
	custom_delay = _custom_delay
	
func onPreAction() -> void:
	setActionDelay(custom_delay if custom_delay >= 0 else duration)
	
func onPostAction() -> void:
	var tween := Game.get_tree().create_tween()
	tween.tween_property(GameObject, property, end_value, duration).as_relative().set_trans(Tween.TRANS_SINE)
