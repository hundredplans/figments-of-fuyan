class_name ChangePhaseAction extends Action

var phase: Game.Phases
func _init(_phase := Game.Phases.START) -> void:
	super()
	phase = _phase
