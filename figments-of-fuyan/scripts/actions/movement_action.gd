class_name MovementAction extends Action

var Card: CardGD
var DestinationTile: TileGD

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func onPreAction() -> void:
	var is_attackable_on_path: bool = DestinationTile.getMovementPathTiles().any(func(x: TileGD): return x != Card.Tile and Game.getFieldCard(x) != null)
	if !Card.canAttack() and is_attackable_on_path: onFailAction()

func onPostAction() -> void:
	Card.Tile.is_card_moving = true
	Card.Tile.setOutlineMaterial()
	
	var tiles: Array = DestinationTile.getMovementPathTiles()
	var actions: Array = [CameraChangeAction.new(Card)]
	
	if Card.turn_state == Game.TurnStates.INACTIVE:
		actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE))
	
	for i in range(1, tiles.size()):
		var MoveToTile: TileGD = tiles[i]
		var Attackable: CardGD = Game.getFieldCard(MoveToTile)
		
		if Attackable == null:
			MoveToTile.is_card_moving = true
			actions.append(MoveToTileAction.new(Card, MoveToTile))
			continue
		actions.append(AttackAction.new(Card, Attackable))
		break
		
	actions.append(MovementFinishAction.new(Card, tiles))
	onAppendAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
