extends BoonGD

const TIER_ONE_ID: int = 4
const TIER_TWO_ID: int = 5
const TIER_THREE_ID: int = 15
const TIER_FOUR_ID: int = 17

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is DeathAction and action.Defender.isAlly(1) and !action.Defender.getAwakenedInCombat():
		onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: DeathAction) -> void:
	var tile_rotation: int = action.Defender.tile_rotation
	var SpawnTile: TileGD = action.Tile
	var NewCard: CardGD = Game.getNewFieldCard(getTierID(), SpawnTile, 1, tile_rotation, 1, true)
	onPushAction(AwakenAction.new(NewCard, SpawnTile))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierID() -> int:
	match tier:
		1: return TIER_ONE_ID
		2: return TIER_TWO_ID
		3: return TIER_THREE_ID
		4: return TIER_FOUR_ID
	return 0
