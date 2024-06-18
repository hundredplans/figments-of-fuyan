class_name DelayActionGD
extends ActionGD
var callable: Callable
const type: int = ActionManagerGD.DELAY

func _init(_callable := Callable(), _is_visible: bool = true, _delay := DelayGD.new()) -> void:
	callable = _callable
	delay = _delay
	is_visible = _is_visible
	super()

func onTrigger() -> void:
	if !callable.is_null():
		callable.call()
