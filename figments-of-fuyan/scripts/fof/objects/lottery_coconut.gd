extends IObjectGD

var stepped_on_choice: String
var stepped_on_card_public_id: int

func onFofInit() -> void:
	super()
	var odds: Resource = load(info.LOTTERY_COCONUT_DATASTORE_PATH)
	stepped_on_choice = Random.getRandomKey(Random.onConvertPercentOdds(odds.getDict()))

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is OccupyAction and action.Tile in occupied_tiles and stepped_on_card_public_id == 0:
			if !action.Card.isAlly(2): # Coco crab can't step on em
				onSteppedOn(action)
			
func onSteppedOn(action: OccupyAction) -> void:
	stepped_on_card_public_id = -1
	var actions: Array = [ClearTileObjectAction.new(self)]
	match stepped_on_choice:
		"heal":
			actions.append(StatAction.new(StatInfo.new(action.Card, Game.Stats.HEALTH, 1)))
		"minitool":
			var id: int = range(8, 13).pick_random()
			var Tool: ToolGD = SavedData.onLoadModel(Helper.getFofInfoID(ToolInfo, id).saved_data.new(id, true), action.Card)
			actions.append(AddToolAction.new(action.Card, Tool))
		"crab":
			var Tile: TileGD = getRandomAdjacentTile()
			if Tile != null:
				var card_tile_rotation: int = Game.getRelativeTileRotation(Tile, action.Tile)
				var Card: CardGD = Game.getNewFieldCard(27, Tile, 2, card_tile_rotation, false)
				stepped_on_card_public_id = action.Card.public_id
				actions.append(AwakenAction.new(Card, Tile))
			
	onRemoveMoveAndAttackActions(action.Card)
	onPushAction(actions)

func onSave() -> SavedDataIObject:
	ability_save['stepped_on_choice'] = stepped_on_choice
	ability_save['stepped_on_card_public_id'] = stepped_on_card_public_id
	return super()

func getRandomAdjacentTile() -> TileGD:
	var random_tiles: Array = Game.getAdjacentTiles(getTile())
	var tile_height: int = getTile().getHeight()
	var unit_tiles: Array = Game.getUnitTiles()
	
	random_tiles = random_tiles.filter(func(x: TileGD): return x.occupied_objects.all(func(y: ObjectGD): return !y.isSolid()) and x not in unit_tiles)
	random_tiles.sort_custom(func(x: TileGD, y: TileGD): return abs(x.getHeight() - tile_height) < abs(y.getHeight() - tile_height))
	
	if !random_tiles.is_empty():
		return random_tiles.pick_random()
	return null
	
