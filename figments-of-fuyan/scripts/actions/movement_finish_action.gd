class_name MovementFinishAction extends Action

var tiles: Array
var Card: CardGD
var phase: Game.Phases # Set by level in pre action
var retry_ai_turn: bool

var previous_allies: Array
var previous_enemies: Array
const FINISH_DELAY: float = 0.5

func _init(_Card: CardGD = null, _tiles: Array = [], _previous_allies: Array = [], _previous_enemies: Array = []) -> void:
	super()
	Card = _Card
	tiles = _tiles
	previous_allies = _previous_allies
	previous_enemies = _previous_enemies
	
func setRetryAiTurn(state: bool) -> void:
	retry_ai_turn = state
	
func onPreAction() -> void:
	if Card.isEnemy(0) and !retry_ai_turn and Card.isAlive() and Card.isLevelVisible() and Card.turn_state == Game.TurnStates.ACTIVE:
		setActionDelay(FINISH_DELAY)
	
func onPostAction() -> void:
	for Tile in tiles:
		Tile.is_card_moving = false
		Tile.setOutlineMaterial()
		
	if Card.isWalking(): Card.onIdle()
		
	if !(Card.isEnemy(0) and Card.turn_state == Game.TurnStates.ACTIVE): return
	
	var actions: Array = []
	var is_enemy_phase: bool = phase in [Game.Phases.AI, Game.Phases.NEUTRAL]
	if is_enemy_phase:
		var is_alive: bool = Card.isAlive()
		var retry: bool = retry_ai_turn and is_alive
		
		if Card is not EpicCardGD:
			if retry:
				var ai_turn_action := AITurnAction.new(Card, false, false, previous_allies, previous_enemies)
				actions.append(ai_turn_action)
			elif !retry:
				actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))
				actions.append(AITurnStartAction.new(Card.team))
		elif retry:
			actions.append(AITurnAction.new(Card, false, false, previous_allies, previous_enemies))
			onPushAction(actions)
			return
	
	elif !is_enemy_phase:
		actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))
		actions.append(CameraSpectateGroupAction.new(0))
		
	onAppendAction(actions)
	
func setPhaseByLevel(_phase: Game.Phases) -> void:
	phase = _phase 
	
func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
