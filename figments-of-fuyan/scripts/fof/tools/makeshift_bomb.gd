extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is DeathAction and action.Defender == Card:
		onDeath(action.Tile)
		
func onDeath(Tile: TileGD) -> void:
	var units: Array = []
	var tiles: Array = []
	
	if !ascended:
		tiles = Game.getAdjacentTiles(Tile)
		units = get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.Tile in tiles)
	else:
		tiles = Game.getAdjacentOrCloserTiles(Tile, 2)
		units = Game.getEnemyUnits(Card.team).filter(func(x: CardGD): return x.Tile in tiles)
		
	onPushAction(units.map(func(x: CardGD): return DamageAction.new(Card, x, 1)))
