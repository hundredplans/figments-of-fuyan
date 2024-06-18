class_name ArgDelayActionGD
extends ActionGD

const type: int = ActionManagerGD.ARG_DELAY
var callable: Callable
var after_callable: Callable

func _init(_callable := Callable(), _after_callable := Callable(), _is_visible: bool = true, _delay := DelayGD.new()) -> void:
	callable = _callable
	after_callable = _after_callable
	delay = _delay
	is_visible = _is_visible
	super()

func onTrigger() -> void:
	if !callable.is_null(): callable.call()
	
func onAfterTrigger() -> void:
	if !after_callable.is_null(): after_callable.call()
	#await onVisDelay(active_action.Triggerer.Tile, active_action.delay)
