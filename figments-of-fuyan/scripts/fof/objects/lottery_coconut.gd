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
			if action.Card.info.id != 27: # Coco crab can't step on em
				onPushAction(IObjectActivatedAction.new(self, action))
			
func onIObject(action: Action) -> void:
	stepped_on_card_public_id = -1
	var actions: Array = [ClearTileObjectAction.new(self)]
	match stepped_on_choice:
		"heal":
			actions.append(StatAction.new(StatInfo.new(action.Card, Game.Stats.HEALTH, 1)))
			onRemoveMoveAndAttackActions(action.Card)
		"minitool":
			if !action.Card.getTool() != null:
				var id: int = range(8, 13).pick_random()
				var Tool: ToolGD = SavedData.onLoadModel(Helper.getFofInfoID(ToolInfo, id).saved_data.new(id, true), action.Card)
				actions.append(AddToolAction.new(action.Card, Tool))
				onRemoveMoveAndAttackActions(action.Card)
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
	
const NEGATIVE_TRANSFORM: int = -10
const POSITIVE_TRANSFORM: float = 0.5
const CHANCE_TO_STEP_ON_WHEN_INJURED_IN_COMBAT: float = 0.5
# If out of combat -10, if injured and in combat +0.5% with a 50% chance
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	if !tiles_to_value.has(getTile()): return
	if !DFL.Card.isInCombat(): tiles_to_value[getTile()] += NEGATIVE_TRANSFORM
	elif DFL.Card.isHealable() and Random.rollFloat(CHANCE_TO_STEP_ON_WHEN_INJURED_IN_COMBAT):
		tiles_to_value[getTile()] += POSITIVE_TRANSFORM
