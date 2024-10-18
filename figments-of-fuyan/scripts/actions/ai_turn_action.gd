class_name AITurnAction extends Action

var Card: CardGD
func _init(_Card: CardGD) -> void:
	super()
	Card = _Card
		
func onPostAction() -> void:
	var tiles: Array = Game.getsetMovementRange(Card)
	tiles.erase(Card.Tile)
	var attackables: Array = tiles.filter(func(x: TileGD): return Game.getFieldCard(x))
	var attackable: TileGD
	if !attackables.is_empty(): attackable = attackables.pick_random()
	
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE), MovementAction.new(Card, attackable if attackable != null else tiles.pick_random())]
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
