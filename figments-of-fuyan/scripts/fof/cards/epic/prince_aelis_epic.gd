extends EpicCardGD

const SLEEP_DELAY: float = 2.0
const ROYAL_BUFF_SPECTATE_DELAY: float = 1.0
const ROYAL_BUFF_DELAY: float = 2.0
const SUMMON_SPECTATE_DELAY: float = 1.0
const SUMMON_DELAY: float = 2.0
const ROYAL_BUFF_MINIMUM_ALLY_IN_VISION: int = 1
const SLEEP_OFF_COOLDOWN_ROLL_CHANCE: float = 0.5
const ENERGY_TOTAL_STOP_SUMMON: int = 10
const ENERGY_TOTAL_DECREASE_SUMMON_ODDS: int = 5
const LOWER_ODDS_TO_SUMMON: float = 0.3
const HIGHER_ODDS_TO_SUMMON: float = 0.66

var solo_spawn_ids: Array = [73, 69, 67, 62, 61]
var duo_spawn_ids: Array = [64, 60, 66, 65, 71, 58, 59]

#region Default
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is AddStatusEffectAction and action.StatusEffect != null\
		and action.StatusEffect.Card != null and action.StatusEffect.Card.isAlly(team) and action.StatusEffect.info.id == FATIGUE_ID:
			action.onFailAction()
			action.StatusEffect.onClear()

func onUseBossIntent(enemies: Array, allies: Array, _tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	match boss_intent.name:
		"Sleep": actions = onSleep(use_type)
		"SoloSpawn": actions = onSoloSpawn(use_type)
		"DuoSpawn": actions = onDuoSpawn(use_type)
		"RoyalBoon": actions = onRoyalBoon(allies, use_type)
		
	if !enemies.is_empty() and use_type == UseType.START:
		var EnemyCard: CardGD = enemies.pick_random()
		var relative_tile_rotation: int = Game.getRelativeTileRotation(getTile(), EnemyCard.getTile())
		actions.push_front(ChangeTileRotationAction.new(self, relative_tile_rotation))
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
func onChangeBossIntent(boss_intents: Array, _enemies: Array, _allies: Array) -> BossIntent:
	var phase: int = getPhase()
	if phase == 1:
		var all_allies: Array = Game.getAllyUnits(team).filter(func(x: CardGD): return x != self)
		var energy_total: int = all_allies.reduce(func(a: int, x: CardGD): return x.energy + a, 0)
		if energy_total >= ENERGY_TOTAL_STOP_SUMMON:
			boss_intents = onKeepByNames(boss_intents, ["Sleep", "RoyalBoon"])
		elif energy_total >= ENERGY_TOTAL_DECREASE_SUMMON_ODDS: # >= 5 energy
			var is_summon: bool = Random.rollFloat(LOWER_ODDS_TO_SUMMON)
			var keeps: Array = ["SoloSpawn", "DuoSpawn"] if is_summon else ["RoyalBoon", "Sleep"]
			boss_intents = onKeepByNames(boss_intents, keeps)
		else: # 5 < Energy
			var is_summon: bool = Random.rollFloat(HIGHER_ODDS_TO_SUMMON)
			var keeps: Array = ["SoloSpawn", "DuoSpawn"] if is_summon else ["RoyalBoon", "Sleep"]
			boss_intents = onKeepByNames(boss_intents, keeps)
		if boss_intents.is_empty(): return getBossIntentByName("Sleep")
		return boss_intents.pick_random()
	return null
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, _enemies: Array, _allies: Array) -> bool:
	var condition_result: BossIntentConditionResult
	match conditional_boss_intent.name:
		"RoyalBoon": condition_result = onRoyalBoonCondition()
		_: condition_result = BossIntentConditionResult.new(true)
	boss_datastore.setConditionResult(condition_result, conditional_boss_intent.name)
	return condition_result.state
#endregion
		
#region Sleep
func onSleep(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "BossSleep")
		animation_action.setActionDelay(SLEEP_DELAY)
		actions.append(animation_action)
	return actions
	
func onSleepSetIntents() -> BossTileIntents: return BossTileIntents.new()
#endregion
	
#region Solo Spawn
func onSoloSpawn(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(SUMMON_DELAY)
		actions.append(animation_action)
		var chosen_tiles: Array = boss_datastore.getTileResults().keys().filter(func(x: TileGD): return x != null and !x.isSolid() and !x.isOccupied())
		for SummonTile: TileGD in chosen_tiles:
			var AllyCard: CardGD = Game.getNewFieldCard(solo_spawn_ids.pick_random(), SummonTile, team, range(6).pick_random(), false, true)
			actions.append(AwakenAction.new(AllyCard, SummonTile))
			actions.append(ChangeTurnStateAction.new(AllyCard, Game.TurnStates.INACTIVE))
			
			var camera_change_action := CameraChangeAction.new(AllyCard)
			camera_change_action.setActionDelay(SUMMON_SPECTATE_DELAY)
			actions.append(camera_change_action)
		
		actions.append(ClearTileIntentsAction.new())
	return actions
	
func onSoloSpawnSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return !x.isOccupied() and !x.isSolid())
	tiles.shuffle()
	tiles = tiles.filter(func(x: TileGD): return x != null)
	tiles.resize(1)
	
	for SummonTile: TileGD in tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.YELLOW, null, SummonTile.getCoords()))
		tile_results[SummonTile] = ""
	return BossTileIntents.new(tile_intents, tile_results)
#endregion
	
#region Duo Spawn
func onDuoSpawn(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(SUMMON_DELAY)
		actions.append(animation_action)
		var chosen_tiles: Array = boss_datastore.getTileResults().keys().filter(func(x: TileGD): return x != null and !x.isSolid() and !x.isOccupied())
		for SummonTile: TileGD in chosen_tiles:
			var AllyCard: CardGD = Game.getNewFieldCard(duo_spawn_ids.pick_random(), SummonTile, team, range(6).pick_random(), false, true)
			actions.append(AwakenAction.new(AllyCard, SummonTile))
			actions.append(ChangeTurnStateAction.new(AllyCard, Game.TurnStates.INACTIVE))
			
			var camera_change_action := CameraChangeAction.new(AllyCard)
			camera_change_action.setActionDelay(SUMMON_SPECTATE_DELAY)
			actions.append(camera_change_action)
		
		actions.append(ClearTileIntentsAction.new())
	return actions
	
func onDuoSpawnSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return !x.isOccupied() and !x.isSolid())
	tiles.shuffle()
	tiles = tiles.filter(func(x: TileGD): return x != null)
	tiles.resize(2)
	
	for SummonTile: TileGD in tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.YELLOW, null, SummonTile.getCoords()))
		tile_results[SummonTile] = ""
	return BossTileIntents.new(tile_intents, tile_results)
#endregion
	
#region Royal Buff
func onRoyalBoon(allies: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "BossBuff")
		animation_action.setActionDelay(ROYAL_BUFF_DELAY)
		actions.append(animation_action)
		
		if !allies.is_empty():
			var AllyCard: CardGD = allies.pick_random()
			var camera_change_action := CameraChangeAction.new(AllyCard)
			camera_change_action.setActionDelay(ROYAL_BUFF_SPECTATE_DELAY)
			actions.append(StatAction.new(StatInfo.new(AllyCard, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH], [1, 1])))
			actions.append(camera_change_action)
		actions.append(ClearTileIntentsAction.new())
	return actions
	
func onRoyalBoonSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	for Card: CardGD in Game.getAllyUnits(team):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(Vector4i.ZERO, false), getCoords()))
	return BossTileIntents.new(tile_intents, {})
	
func onRoyalBoonCondition() -> BossIntentConditionResult:
	return BossIntentConditionResult.new(getVisibleFieldCardsAllies().size() >= ROYAL_BUFF_MINIMUM_ALLY_IN_VISION)
#endregion
