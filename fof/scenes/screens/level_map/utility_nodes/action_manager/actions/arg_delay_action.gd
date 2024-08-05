class_name ArgDelayActionGD
extends ActionGD

const type: int = ActionManagerGD.ARG_DELAY
var callable: Callable
var after_callable: Callable
var call_with_result: bool = false
var first_result: Variant

func _init(_callable := Callable(), _after_callable := Callable(), _is_visible: bool = true, _delay := DelayGD.new(), _call_with_result: bool = false) -> void:
	callable = _callable
	after_callable = _after_callable
	delay = _delay
	is_visible = _is_visible
	call_with_result = _call_with_result
	super()

func onTrigger() -> void:
	if !callable.is_null(): first_result = await callable.call()
	
func onAfterTrigger() -> void:
	if !after_callable.is_null():
		if call_with_result: after_callable.call(first_result)
		else: after_callable.call()
