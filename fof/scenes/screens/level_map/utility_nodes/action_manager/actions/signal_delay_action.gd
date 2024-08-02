class_name SignalDelayActionGD
extends ActionGD
const type: int = ActionManagerGD.SIGNAL_DELAY

var already_emit: bool = false
var callable: Callable
var after_callable: Callable
var sig: Signal

func _init(_callable := Callable(), _after_callable := Callable(), _is_visible: bool = true, _sig: Signal = Signal()) -> void:
	callable = _callable
	after_callable = _after_callable
	is_visible = _is_visible
	sig = _sig
	sig.connect(onSigEmit)
	delay = DelayGD.new()
	super()
	
func onSigEmit() -> void: already_emit = true
	
func onTrigger() -> void:
	if !callable.is_null(): callable.call()

func onAfterTrigger() -> void:
	if !after_callable.is_null(): after_callable.call()
