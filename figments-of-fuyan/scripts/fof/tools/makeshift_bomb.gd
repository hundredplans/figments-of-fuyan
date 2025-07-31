extends ToolGD

const MINIMUM_TIER_DAMAGE_ONLY_ENEMIES: int = 2
const MINIMUM_TIER_DAMAGE_IN_VISION: int = 3

const TIER_ONE_EXPLOSION_RANGE: int = 1
const TIER_TWO_EXPLOSION_RANGE: int = 2

const TIER_ONE_DAMAGE: int = 1
const TIER_TWO_DAMAGE: int = 1
const TIER_THREE_DAMAGE: int = 1
const TIER_FOUR_DAMAGE: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is DeathAction and action.Defender == Card:
		onPushAction(ToolActivatedAction.new(self, action))
		
func onToolAction(action: DeathAction) -> void:
	var Tile: TileGD = action.Tile
	var units: Array = []
	var tiles: Array = []
	
	if tier < MINIMUM_TIER_DAMAGE_IN_VISION:
		tiles = Game.getAdjacentOrCloserTiles(Tile, getExplosionRange())
		units = Game.getEnemyUnits(Card.getTeam()) if tier >= MINIMUM_TIER_DAMAGE_ONLY_ENEMIES else Game.getUnits()
		units = units.filter(func(x: CardGD): return x.getTile() in tiles)
	else:
		units = action.getGameObjectsInVision().filter(func(x: GameObjectGD): return x is CardGD)
		if tier >= MINIMUM_TIER_DAMAGE_ONLY_ENEMIES:
			units = units.filter(func(x: CardGD): return Card.isEnemy(x.getTeam()))
			
	onPushAction(DamageAction.new(Card, units, getExplosionDamage()))
	
func getExplosionRange() -> int:
	match tier:
		1: return TIER_ONE_EXPLOSION_RANGE
		2: return TIER_TWO_EXPLOSION_RANGE
		3: return 0
		4: return 0
	return 0

func getExplosionDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
