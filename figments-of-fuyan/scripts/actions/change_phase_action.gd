class_name ChangePhaseAction extends Action

const CHANGE_PHASE_DELAY: float = 1.0

var phase: Game.Phases
func _init(_phase := Game.Phases.START) -> void:
	super()
	phase = _phase

func onPreAction() -> void:
	if phase in [Game.Phases.AI, Game.Phases.NEUTRAL]:
		if phase == Game.Phases.NEUTRAL and Game.getAllyUnits(2).is_empty(): return # If no neutrals in map
		setActionDelay(CHANGE_PHASE_DELAY)
