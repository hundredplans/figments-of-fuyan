extends ToolGD

const TIER_ONE_STAT_BUFF: int = 1
const TIER_TWO_STAT_BUFF: int = 1
const TIER_THREE_STAT_BUFF: int = 1
const TIER_FOUR_STAT_BUFF: int = 2

const TIER_ONE_TEMP_STAT_BUFF: int = 0
const TIER_TWO_TEMP_STAT_BUFF: int = 1
const TIER_THREE_TEMP_STAT_BUFF: int = 2
const TIER_FOUR_TEMP_STAT_BUFF: int = 2

func getStatBuff(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_STAT_BUFF
		2: return TIER_TWO_STAT_BUFF
		3: return TIER_THREE_STAT_BUFF
		4: return TIER_FOUR_STAT_BUFF
	return 0
	
func getTempStatBuff() -> int:
	match tier:
		1: return TIER_ONE_TEMP_STAT_BUFF
		2: return TIER_TWO_TEMP_STAT_BUFF
		3: return TIER_THREE_TEMP_STAT_BUFF
		4: return TIER_FOUR_TEMP_STAT_BUFF
	return 0

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles() -> ActiveEffectTiles:
	var pickable_tiles: Array = ([Card.Tile] if info.id != 1 or Card.isHealable() else [])
	return ActiveEffectTiles.new([Card.Tile], pickable_tiles)
	
func isActiveEffectDisabled() -> bool:
	return super() or (info.id == 1 and !Card.isHealable())

func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var type: Game.Stats
	var turns: int = 1
	
	match info.id:
		1: type = Game.Stats.HEALTH; turns = 0
		4: type = Game.Stats.ATTACK
		6: type = Game.Stats.MAX_SPEED
		
	onPushAction(StatAction.new(StatInfo.new(Card, type, getTempStatBuff(), turns)))
		
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	match info.id:
		# If you're injured use heal 1 hp
		1:
			if Card.isInjured():
				return active_effect_tiles.pickable_tiles[0]
		# If you can get a kill out of it use 1 att
		4:
			return null
			if DFL.is_kill_guaranteed: return null
			
			DFL.onAddTempAtt(1)
			var path: Array = DFL.getKillPath()
			DFL.onAddTempAtt(-1)
			
			if path.is_empty(): return null
			
			return active_effect_tiles.pickable_tiles[0]
		# If speed is debuffed or a killable enemy is 1 tile from being attackable
		6:
			return null
			if DFL.is_kill_guaranteed: return null
			elif DFL.is_card_attack: return null
			elif Card.speed < Card.max_speed: return active_effect_tiles.pickable_tiles[0]
			
			var enemies: Array = DFL.enemies.filter(func(x: CardGD): return DFL.isAttackableKillable(x, Card))
			var any_enemy_one_tile_away: bool = DFL.enemies.any(func(x: CardGD): return Card.getAttackDistanceFromEnemy(x.getTile(), Card.getTile()) == 1)
			return active_effect_tiles.pickable_tiles[0] if any_enemy_one_tile_away else null
	return null
		
func onToolEquipped() -> void:
	super()
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)
	
func onToolUnequipped() -> void:
	super()
	var types: Array = []
	match info.id:
		1: types.append(Game.Stats.MAX_HEALTH); types.append(Game.Stats.HEALTH)
		4: types.append(Game.Stats.ATTACK)
		6: types.append(Game.Stats.MAX_SPEED)
		
	var values: Array = []
	values.resize(types.size())
	values.fill(-getStatBuff())
	var stat_action := StatAction.new(StatInfo.new(Card, types, values))
	onPushAction(ToolActivatedAction.new(self, stat_action))

func onToolHolderAwakened() -> void:
	super()
	var stat_action := getStatAction(getStatBuff())
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func getStatAction(value: int) -> StatAction:
	var types: Array = []
	match info.id:
		1: types.append(Game.Stats.MAX_HEALTH); types.append(Game.Stats.HEALTH)
		4: types.append(Game.Stats.ATTACK)
		6: types.append(Game.Stats.MAX_SPEED)
		
	var values: Array = []
	values.resize(types.size())
	values.fill(value)
	var stat_action := StatAction.new(StatInfo.new(Card, types, values))
	return stat_action
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if tier == old_tier: return
	
	var current_value: int = getStatBuff()
	var old_value: int = getStatBuff(old_tier)
	var new_value: int = current_value - old_value
	onPushAction(ToolActivatedAction.new(self, getStatAction(new_value)))
	
func onToolHolderDeath() -> void:
	super()

func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)
