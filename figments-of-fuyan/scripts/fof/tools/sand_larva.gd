extends ToolGD

const REVEAL_ID: int = 6

const TIER_ONE_ENEMY_COUNT: int = 1
const TIER_TWO_ENEMY_COUNT: int = 2
const TIER_THREE_ENEMY_COUNT: int = 2
const TIER_FOUR_ENEMY_COUNT: int = 3

const TIER_ONE_TURNS: int = 1
const TIER_TWO_TURNS: int = 1
const TIER_THREE_TURNS: int = 2
const TIER_FOUR_TURNS: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()
	
func onToolHolderAwakened() -> void:
	super()
	
func onToolHolderDeath() -> void:
	super()

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Sandy Spy":
		return ActiveEffectTiles.new([Card.Tile], [Card.Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Sandy Spy":
		var enemies: Array = Game.getEnemyUnits(Card.team).filter(func(x: CardGD): return !x.isRevealed(-1))
		if enemies.is_empty(): return
		enemies.shuffle()
		enemies.resize(getEnemyCount())
		enemies = enemies.filter(func(x: CardGD): return x != null)
		
		var turns: int = getRevealedTurns()
		for EnemyCard: CardGD in enemies:
			EnemyCard.onCreateBaseStatusEffect(REVEAL_ID, turns)

# Use when possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Sandy Spy")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)

func getEnemyCount() -> int:
	match tier:
		1: return TIER_ONE_ENEMY_COUNT
		2: return TIER_TWO_ENEMY_COUNT
		3: return TIER_THREE_ENEMY_COUNT
		4: return TIER_FOUR_ENEMY_COUNT
	return 0
	
func getRevealedTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
