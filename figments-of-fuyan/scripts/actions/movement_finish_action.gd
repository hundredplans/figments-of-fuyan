class_name MovementFinishAction extends Action

var tiles: Array
var Card: CardGD

func _init(_Card: CardGD = null, _tiles: Array = []) -> void:
	super()
	Card = _Card
	tiles = _tiles
	
func onPostAction() -> void:
	for Tile in tiles:
		Tile.is_card_moving = false
		Tile.setOutlineMaterial()
	if Card.isWalking(): Card.onIdle()
	
	if Card.isEnemy(0) and Card.turn_state == Game.TurnStates.ACTIVE:
		var NewCard: CardGD = Game.getNextInactiveCard(Card.team)
		var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED),\
		AITurnAction.new(NewCard) if NewCard != null else ChangePhaseAction.new(Game.Phases.NEUTRAL if Card.isAlly(1) else Game.Phases.HAND)]
		onAppendAction(actions)
	
