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
		elif action is DeathAction and boss_intent != null and boss_intent.name == "RoyalBoon":
			onRoyalBoonPotentialDeath(action)

func onUseBossIntent(enemies: Array, allies: Array, _tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	match boss_intent.name:
		"Sleep": actions = onSleep(enemies, use_type)
		"SoloSpawn": actions = onSoloSpawn(use_type)
		"DuoSpawn": actions = onDuoSpawn(use_type)
		"RoyalBoon": actions = onRoyalBoon(allies, use_type)
		
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
func onChangeBossIntent(boss_intents: Array, _enemies: Array, _allies: Array) -> BossIntent:
	var phase: int = getPhase()
	if phase == 1:
		var all_allies: Array = Game.getAllyUnits(team).filter(func(x: CardGD): return x != self)
		var energy_total: int = all_allies.reduce(func(a: int, x: CardGD): return x.energy + a, 0)
		if energy_total >= ENERGY_TOTAL_STOP_SUMMON:
			boss_intents = onKeepByNames(boss_intents, ["Sleep", "RoyalBoon"])
		else: # 10 < energy
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
func onSleep(enemies: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		if !enemies.is_empty():
			var EnemyCard: CardGD = enemies.pick_random()
			var relative_tile_rotation: int = Game.getRelativeTileRotation(getTile(), EnemyCard.getTile())
			actions.append(ChangeTileRotationAction.new(self, relative_tile_rotation))
			
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
		var tiles: Array = boss_datastore.getTileResults().keys()
		actions.append(ChangeTileRotationAction.new(self,\
			Game.getRelativeTileRotation(getTile(), tiles.pick_random())))
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(SUMMON_DELAY)
		actions.append(animation_action)
		
		var chosen_tiles: Array = tiles.filter(func(x: TileGD): return x != null and !x.isSolid() and !x.isOccupied())
		for SummonTile: TileGD in chosen_tiles:
			var AllyCard: CardGD = Game.getNewFieldCard(solo_spawn_ids.pick_random(), SummonTile, team, range(6).pick_random(), tier, true)
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
		var tiles: Array = boss_datastore.getTileResults().keys()
		actions.append(ChangeTileRotationAction.new(self,\
			Game.getRelativeTileRotation(getTile(), tiles.pick_random())))
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(SUMMON_DELAY)
		actions.append(animation_action)
		var chosen_tiles: Array = tiles.filter(func(x: TileGD): return x != null and !x.isSolid() and !x.isOccupied())
		for SummonTile: TileGD in chosen_tiles:
			var AllyCard: CardGD = Game.getNewFieldCard(duo_spawn_ids.pick_random(), SummonTile, team, range(6).pick_random(), tier, true)
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
		var ValidAlly: CardGD = boss_datastore.getConditionResult("RoyalBoon").getValidAlly()
		
		if ValidAlly.isAlive():
			var relative_tr: int = Game.getRelativeTileRotation(getTile(), ValidAlly.getTile())
			actions.append(ChangeTileRotationAction.new(self, relative_tr))
		
		var animation_action := AnimationAction.new(self, "BossBuff")
		animation_action.setActionDelay(ROYAL_BUFF_DELAY)
		actions.append(animation_action)
		
		if !ValidAlly.isAlive(): return actions
		
		var camera_change_action := CameraChangeAction.new(ValidAlly)
		camera_change_action.setActionDelay(ROYAL_BUFF_SPECTATE_DELAY)
		actions.append(StatAction.new(StatInfo.new(ValidAlly, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1, 1])))
		actions.append(camera_change_action)
		actions.append(ClearTileIntentsAction.new())
	return actions
	
func onRoyalBoonSetIntents() -> BossTileIntents:
	var ValidAlly: CardGD = boss_datastore.getConditionResult("RoyalBoon").getValidAlly()
	var tile_intents: Array[TileIntentDatastore] = []
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(Vector4i.ZERO), ValidAlly.getCoords()))
	return BossTileIntents.new(tile_intents, {})
	
func onRoyalBoonCondition() -> BossIntentConditionResult:
	var valid_allies: Array = getVisibleFieldCardsAllies()
	if valid_allies.size() >= ROYAL_BUFF_MINIMUM_ALLY_IN_VISION:
		var ValidAlly: CardGD = valid_allies.pick_random()
		var royal_boon_condition := BossIntentConditionResultRoyalBoon.new(true)
		royal_boon_condition.setValidAllyPublicId(ValidAlly.public_id)
		return royal_boon_condition
	return BossIntentConditionResultRoyalBoon.new(false)
	
func onRoyalBoonPotentialDeath(action: DeathAction) -> void:
	var ValidAlly: CardGD = boss_datastore.getConditionResult("RoyalBoon").getValidAlly()
	if action.Defender != ValidAlly: return	
	var valid_ally_coords: Vector4i = action.Tile.getCoords()
	var tile_intents: Array[TileIntentDatastore] = boss_datastore.getTileIntents().duplicate()
	tile_intents = tile_intents.filter(func(x: TileIntentDatastore): return x.getCoords() != valid_ally_coords)
	boss_datastore.onFirstUpdateTileIntents(tile_intents)
#endregion
