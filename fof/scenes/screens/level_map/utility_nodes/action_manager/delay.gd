class_name DelayGD
extends Resource

# Before it starts
var start_delay: float
# After the first trigger
var delay: float
# Nothing happens after this delay
var end_delay: float

func _init(_delay: float = 0, _start_delay: float = 0, _end_delay: float = 0) -> void:
	delay = _delay
	start_delay = _start_delay
	end_delay = _end_delay
