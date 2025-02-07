class_name MovementFinishAction extends Action

var tiles: Array
var Card: CardGD
var phase: Game.Phases # Set by level in pre action
var retry_ai_turn: bool

var previous_allies: Array
var previous_enemies: Array

func _init(_Card: CardGD = null, _tiles: Array = [], _previous_allies: Array = [], _previous_enemies: Array = []) -> void:
	super()
	Card = _Card
	tiles = _tiles
	previous_allies = _previous_allies
	previous_enemies = _previous_enemies
	
func setRetryAiTurn(state: bool) -> void:
	retry_ai_turn = state
	
func onPostAction() -> void:
	for Tile in tiles:
		Tile.is_card_moving = false
		Tile.setOutlineMaterial()
		
	if Card.isWalking():
		Card.onIdle()
	
	if Card.isEnemy(0) and Card.turn_state == Game.TurnStates.ACTIVE:
		var is_alive: bool = Card.isAlive()
		var actions: Array = []
		if phase in [Game.Phases.AI, Game.Phases.NEUTRAL]:
			var retry: bool = retry_ai_turn and is_alive
			if retry:
				actions.append(AITurnAction.new(Card, false, false, previous_allies, previous_enemies))
			else:
				actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))
				actions.append(AITurnStartAction.new(Card.team))
		else:
			actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))
			actions.append(CameraSpectateGroupAction.new(0))
		
		onAppendAction(actions)
	
func setPhaseByLevel(_phase: Game.Phases) -> void:
	phase = _phase 
	
func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
