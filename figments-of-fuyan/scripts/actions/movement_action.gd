class_name MovementAction extends Action

var Card: CardGD
var DestinationTile: TileGD

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func onPreAction() -> void:
	var is_attackable_on_path: bool =  DestinationTile.getMovementPathTiles().any(func(x: TileGD): return x != Card.Tile and Game.getFieldCard(x) != null)
	if !Card.canAttack() and is_attackable_on_path: onFailAction()
	

func onPostAction() -> void:
	Card.onWalk()
	
	Card.Tile.is_card_moving = true
	Card.Tile.setOutlineMaterial()
	
	var tiles: Array = DestinationTile.getMovementPathTiles()
	var cards: Array = Game.getEnemyUnits(Card.team)
	
	for i in range(1, tiles.size()):
		var MoveToTile: TileGD = tiles[i]
		var Attackable: CardGD = Game.getFieldCard(MoveToTile)
		
		if Attackable == null:
			MoveToTile.is_card_moving = true
			onAppendAction(MoveToTileAction.new(Card, MoveToTile))
			continue
		onAppendAction(AttackAction.new(Card, Attackable))
		break
	onAppendAction(MovementFinishAction.new(Card, tiles))
