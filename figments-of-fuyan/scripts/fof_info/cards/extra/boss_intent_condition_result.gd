class_name BossIntentConditionResult extends Resource

@export var state: bool
func _init(_state: bool = false) -> void:
	state = _state
	
func setState(_state: bool) -> void:
	state = _state
func onSave() -> void: pass
func onLoad() -> void: pass
