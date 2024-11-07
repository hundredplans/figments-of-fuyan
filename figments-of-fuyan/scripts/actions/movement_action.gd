class_name MovementAction extends Action

var Card: CardGD
var DestinationTile: TileGD

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func onPreAction() -> void:
	var is_attackable_on_path: bool = DestinationTile.getMovementPathTiles().any(func(x: TileGD): return x.occupy_state != TileGD.OccupyStates.NULL)
	if !Card.canAttack() and is_attackable_on_path: onFailAction()

func onPostAction() -> void:
	Card.Tile.is_card_moving = true
	Card.Tile.setOutlineMaterial()
	
	var tiles: Array = DestinationTile.getMovementPathTiles()
	var actions: Array = [CameraChangeAction.new(Card)]
	
	if Card.turn_state == Game.TurnStates.INACTIVE:
		actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE))
	
	var ally_cards: Array = Game.getAllyUnits(Card.team)
	for ally_card in ally_cards.filter(func(x: CardGD): return x.turn_state == Game.TurnStates.ACTIVE and x != Card):
		actions.append(ChangeTurnStateAction.new(ally_card, Game.TurnStates.PASSED))
	
	for i in range(1, tiles.size()):
		var MoveToTile: TileGD = tiles[i]
		
		var Attackables: Array = []
		match MoveToTile.occupy_state:
			TileGD.OccupyStates.NULL: pass
			TileGD.OccupyStates.ATTACKABLE_IOBJECT: Attackables = MoveToTile.getAttackableIObjects()
			_: Attackables.append(Game.getFieldCard(MoveToTile))
		
		if Attackables.is_empty():
			MoveToTile.is_card_moving = true
			actions.append(MoveToTileAction.new(Card, MoveToTile))
			continue
		actions.append(AttackAction.new(Card, Attackables))
		break
		
	actions.append(MovementFinishAction.new(Card, tiles))
	onAppendAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
