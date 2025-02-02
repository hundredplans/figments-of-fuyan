extends Button

var action_lock: bool
var is_ally_spectating: bool
var is_passed_turn: bool
var is_inactive_with_another_active: bool
var is_player_phase: bool
var is_ability_mode: bool
var is_last_ally_alive: bool

func setDisabled() -> void:
	var player_phase_checks: bool = is_ally_spectating and (!is_passed_turn or is_last_ally_alive) and !is_inactive_with_another_active
	disabled = action_lock or (is_player_phase and !player_phase_checks) or is_ability_mode
	
func setActionLock(state: bool) -> void:
	action_lock = state
	setDisabled()
	
func setAbilityMode(state: bool) -> void:
	is_ability_mode = state
	setDisabled()

func setAllySpectating(SpectateObject: GameObjectGD) -> void:
	is_ally_spectating = SpectateObject != null and SpectateObject is CardGD and SpectateObject.isAlly(0)
	if is_ally_spectating: # Important so spawn's can't go into the Card func
		setTurnStates(SpectateObject, true)

func setTurnStates(Card: CardGD, override: bool = false) -> void:
	if is_ally_spectating and (Card == Game.getLevel().getAllySpectateObject() or override):
		is_passed_turn = Card.turn_state == Game.TurnStates.PASSED
		is_inactive_with_another_active = Card.turn_state == Game.TurnStates.INACTIVE and\
			Game.getAllyUnits().any(func(x: CardGD): return x != Card and x.turn_state == Game.TurnStates.ACTIVE)
	
	setDisabled()
	
func setIsLastAllyAlive() -> void:
	is_last_ally_alive = Game.getAllyUnits(0).size() == 1
	setDisabled()

func setPhase(phase: Game.Phases) -> void:
	is_player_phase = phase == Game.Phases.PLAYER
	setDisabled()
