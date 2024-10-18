extends Button

var action_lock: bool
var is_ally_spectating: bool
var is_ally_inactive_active: bool
var is_only_active: bool
var is_player_phase: bool

func setDisabled() -> void:
	var player_phase_checks: bool = is_ally_spectating and is_ally_inactive_active and is_only_active
	disabled = action_lock or (is_player_phase and !player_phase_checks)
	
func setActionLock(state: bool) -> void:
	action_lock = state
	setDisabled()

func setAllySpectating(SpectateObject: GameObjectGD) -> void:
	is_ally_spectating = SpectateObject != null and SpectateObject is CardGD and SpectateObject.isAlly(0)
	setIsAllyInactiveActive(SpectateObject)

func setIsAllyInactiveActive(GameObject: GameObjectGD) -> void:
	var ally_units: Array = Game.getAllyUnits()
	is_only_active = true
	for AllyUnit in ally_units:
		if AllyUnit.turn_state == Game.TurnStates.ACTIVE:
			is_only_active = (AllyUnit == GameObject)
			break
			
	is_ally_inactive_active = GameObject is CardGD and GameObject.isAlly(0) and \
	GameObject.turn_state != Game.TurnStates.PASSED
	
	setDisabled()

func setPhase(phase: Game.Phases) -> void:
	is_player_phase = phase == Game.Phases.PLAYER
	setDisabled()
