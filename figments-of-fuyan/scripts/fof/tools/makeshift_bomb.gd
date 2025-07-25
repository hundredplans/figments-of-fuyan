extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is DeathAction and action.Defender == Card:
		onPushAction(ToolActivatedAction.new(self, action))
		
func onToolAction(action: DeathAction) -> void:
	var Tile: TileGD = action.Tile
	var units: Array = []
	var tiles: Array = []
	
	if tier == 1:
		tiles = Game.getAdjacentTiles(Tile)
		units = get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.Tile in tiles)
	else:
		tiles = Game.getAdjacentOrCloserTiles(Tile, 2)
		units = Game.getEnemyUnits(Card.team).filter(func(x: CardGD): return x.Tile in tiles)
		
	onPushAction(DamageAction.new(Card, units, 1))
