extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidLastWill(action):
		onPushAction(LastWillAction.new(self, action))

func onLastWill(death_action: DeathAction) -> void:
	var SpawnTile: TileGD = death_action.Tile
	var NewCard: CardGD = Game.getNewFieldCard(4, SpawnTile, team, tile_rotation, tier, true)
	onPushAction(AwakenAction.new(NewCard, SpawnTile))
