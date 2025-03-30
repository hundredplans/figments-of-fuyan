class_name EpicCardGD extends CardGD

enum UseType {START, END, RECALCULATE}

var boss_intent: BossIntent
var BossFieldInfo: Node3D

#region Default
func onSave() -> SavedDataBossCard:
	onPreSave()
	return SavedDataBossCard.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, team, ascended, \
	attack, health, speed, max_speed, max_health, energy, draw_order, card_place, turn_state, SavedData.onSaveGroup(status_effects), attacks, attack_range, delayed_stats,\
	ability_save, active_effects, Tool.onSave() if Tool != null else null, SavedData.onSaveGroup(field_effects), anibility_datastore,\
	is_temporary, is_awakened_in_combat, ai_datastore, base_stats,
	overworld_traits, bounty_kills, boss_datastore, card_offset)

func onLoadData(data: SavedData) -> void:
	super(data)
	boss_datastore = data.boss_datastore
	if boss_datastore != null: boss_datastore.onLoad()
	add_to_group("EpicCardsGD")
	
func onLoadDataLevel() -> void:
	super()
	setBossIntentByName()
	
func onFofInit() -> void:
	super()
	onResetBossIntentCooldowns()
	
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is OccupyAction:
			onOccupy(action)
		elif action is ChangeTileRotationAction:
			onChangeTileRotation(action)
		elif action is ChangeBossPhaseAction:
			onChangeBossPhasePostDelay()
#endregion
	
#region Info Getters
func getAttackFromInfo() -> int:
	return info.getAttack(boss_datastore.phase)
	
func getHealthFromInfo() -> int:
	return info.getHealth(boss_datastore.phase)
	
func getSpeedFromInfo() -> int:
	return info.getSpeed(boss_datastore.phase)

func getTopFromInfo() -> float:
	return info.getTop(boss_datastore.phase)
	
func getEyeFromInfo() -> float:
	return info.getEye(boss_datastore.phase)
	
func getStatFromInfo() -> float:
	return info.getStat(boss_datastore.phase)
	
func getNameFromInfo() -> String:
	return info.getName(boss_datastore.phase)

func getModelFromInfo() -> PackedScene:
	return info.getModel(boss_datastore.phase)

func getCollisionShapeFromInfo() -> PackedScene:
	return info.getCollisionShape(boss_datastore.phase)
	
func getPointsFromInfo() -> Array:
	return info.getPoints(boss_datastore.phase)
	
func getArchetypeFromInfo() -> ArchetypeInfo:
	return info.getArchetype(boss_datastore.phase)
	
func getBossIntentsFromInfo() -> Array[BossIntent]:
	return info.getBossIntents(boss_datastore.phase)
	
func getSpeedOrderOverrideFromInfo() -> EpicCardInfo.SpeedOrderOverride:
	return info.getSpeedOrderOverride(boss_datastore.phase)
	
func getChangeDelayFromInfo(delta: int = 0) -> float:
	return info.getChangeDelay(boss_datastore.phase + delta)
#endregion

#region Getters
func getArchetypeEnum(archetype_id: int = getArchetypeFromInfo().id) -> Game.Archetypes:
	return super(archetype_id)
	
func getPhase() -> int:
	return boss_datastore.phase
#endregion

#region Updaters
func onFirstUpdateTileIntents() -> void:
	var method_name: String = "on" + boss_intent.name.replace(" ", "") + "SetIntents"
	var boss_tile_intents: BossTileIntents = call(method_name)
	var old_tile_intents: Array = boss_datastore.getTileIntents()
	
	boss_datastore.setBossTileIntents(boss_tile_intents)
	boss_datastore.onFirstUpdateTileIntents(boss_tile_intents.getTileIntents(), old_tile_intents)
#endregion

#region Setters

#endregion
	
#region Empty Overrides
	
func onCreateInitialActiveAbilities() -> void: # Inte
	return
	
func onAICheckActiveEffectsOnlyDFL(_DFL: DefaultFightLogic, _after_action: MovementFinishAction = null) -> bool:
	return false
#endregion

#region Tile
func onOccupy(action: OccupyAction) -> void:
	boss_datastore.onUpdateTileIntents(action)
	
func onChangeTileRotation(action: ChangeTileRotationAction) -> void:
	boss_datastore.onUpdateTileIntentsRotation(action)
#endregion

#region Boss Field Info
func onCreateFieldInfo() -> void:
	BossFieldInfo = load(info.BOSS_FIELD_INFO_SCENE_PATH).instantiate()
	add_child(BossFieldInfo)
	BossFieldInfo.setInfo(self)
	
func onRemoveFieldInfo() -> void:
	if BossFieldInfo != null:
		BossFieldInfo.queue_free()
#endregion

#region Boss Intent
func getBossIntentByName(_name: String = boss_datastore.boss_intent_name) -> BossIntent:
	var boss_intents: Array[BossIntent] = getBossIntentsFromInfo()
	for _boss_intent: BossIntent in boss_intents:
		if _boss_intent.name == _name:
			return _boss_intent
	return null
	
func setBossIntent(_boss_intent: BossIntent) -> void:
	boss_intent = _boss_intent

	boss_datastore.boss_intent_name = boss_intent.name
	if BossFieldInfo != null: BossFieldInfo.onUpdateBossIntent()
	
	if Tile != null: onFirstUpdateTileIntents()
	else: boss_datastore.onFirstUpdateTileIntents(boss_datastore.getTileIntents()) # When first loading in
	
func setBossIntentByName() -> void:
	var _boss_intent: BossIntent = getBossIntentByName()
	setBossIntent(_boss_intent)
	
func onChangeBossIntent(_boss_intents: Array, _enemies: Array, _allies: Array) -> BossIntent: return null
func onResetBossIntentCooldowns() -> void:
	for _boss_intent: BossIntent in getBossIntentsFromInfo():
		boss_datastore.boss_intent_name_to_cooldown[_boss_intent.name] = 0
		
func onEmptyBossIntentNameCooldowns() -> void:
	boss_datastore.boss_intent_name_to_cooldown = {}
		
func onFilterBossIntents(enemies: Array, allies: Array) -> Array:
	var in_combat: bool = !enemies.is_empty()
	var boss_intents: Array = getBossIntentsPool(enemies, allies)
	boss_intents = boss_intents.filter(func(x: BossIntent):\
		return boss_datastore.boss_intent_name_to_cooldown[x.name] == 0 and\
		(x.combat_type == x.CombatType.BOTH or\
		((x.combat_type == x.CombatType.IN_COMBAT and in_combat) or (x.combat_type == x.CombatType.OUT_OF_COMBAT and !in_combat))))
	return boss_intents
	
func getBossIntentsPool(enemies: Array, allies: Array) -> Array:
	return getBossIntentsFromInfo().filter(onCheckBossIntentCondition.bind(enemies, allies))
	
func onCheckBossIntentCondition(_boss_intent: BossIntent, _enemies: Array, _allies: Array) -> bool: return false
func onIntentUsed(_boss_intent: BossIntent, _use_type: UseType, _actions: Array) -> void: return


#endregion

#region Card Turn Passed
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
	if self != Card: return
	
	for boss_intent_name in boss_datastore.boss_intent_name_to_cooldown:
		if boss_datastore.boss_intent_name_to_cooldown[boss_intent_name] > 0:
			boss_datastore.boss_intent_name_to_cooldown[boss_intent_name] -= 1
			
	boss_datastore.boss_intent_used_this_turn = false
#endregion

#region Phase Change
func onChangeBossPhase() -> void:
	boss_datastore.phase += 1
	onEmptyBossIntentNameCooldowns()
	onResetBossIntentCooldowns()
	onForceAction(CameraChangeAction.new(self))
			
func onChangeBossPhasePostDelay() -> void:
	var new_attack: int = getAttackFromInfo()
	var new_max_health: int = getHealthFromInfo()
	var new_speed: int = getSpeedFromInfo()
	
	var attack_delta: int = new_attack - attack
	var health_delta: int = 0 if new_max_health == 0 else new_max_health - max_health
	var speed_delta: int = new_speed - speed
	
	var stat_info := StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED], [attack_delta, health_delta, speed_delta])
	var actions: Array = [StatAction.new(stat_info)]
	
	if getModelFromInfo() != null:
		onRemoveModel()
		onCreateModel()
		
	onPushAction(actions)
	
func onPhaseChangeBossIntent(intent_name: String) -> void:
	var new_boss_intent: BossIntent = getBossIntentByName(intent_name)
	boss_datastore.onResetConditionResults()
	onForceAction(ChangeBossIntentAction.new(new_boss_intent, true))
#endregion

#region Helper
func onHasNonAttackIntents(boss_intents: Array) -> bool:
	return boss_intents.any(func(x: BossIntent): return x.type not in [BossIntent.IntentType.ATTACK, BossIntent.IntentType.MOVEMENT_ATTACK])

func onHasAttackIntents(boss_intents: Array) -> bool:
	return boss_intents.any(func(x: BossIntent): return x.type in [BossIntent.IntentType.ATTACK, BossIntent.IntentType.MOVEMENT_ATTACK])

func onHasIntentName(boss_intents: Array, intent_name: String) -> bool:
	return boss_intents.any(func(x: BossIntent): return x.name == intent_name)

func onKeepByNames(boss_intents: Array, intent_names: Array) -> Array:
	return boss_intents.filter(func(x: BossIntent): return x.name in intent_names)

func onKeepByName(boss_intents: Array, intent_name: String) -> Array:
	return boss_intents.filter(func(x: BossIntent): return x.name == intent_name)

func onKeepAttacks(boss_intents: Array) -> Array:
	return boss_intents.filter(func(x: BossIntent): return x.type in [BossIntent.IntentType.ATTACK, BossIntent.IntentType.MOVEMENT_ATTACK])

func onKeepNonAttacks(boss_intents: Array) -> Array:
	return boss_intents.filter(func(x: BossIntent): return x.type not in [BossIntent.IntentType.ATTACK, BossIntent.IntentType.MOVEMENT_ATTACK])

func getDistantToEnemiesTiles(enemies: Array, tiles: Array) -> Array:
	if enemies.is_empty(): return tiles
	tiles = tiles.duplicate()
	var tiles_to_distance: Dictionary = {}
	for OtherTile: TileGD in tiles:
		var distance: int = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), OtherTile.getCoords())).min()
		tiles_to_distance[OtherTile] = distance
			
	tiles.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_distance[x] > tiles_to_distance[y])
	return tiles
	
func getAllyVisionTiles(tiles: Array) -> Array:
	var ally_vision: Array = Game.getTeamVision(0)
	if !ally_vision.is_empty():
		return tiles.filter(func(x: TileGD): return x in ally_vision)
	return tiles
	
func getUnoccupiedTiles(tiles: Array) -> Array:
	var unit_tiles: Array = Game.getUnitTiles()
	return tiles.filter(func(x: TileGD): return x not in unit_tiles)
	
func getCloseToEnemiesTiles(enemies: Array, tiles: Array) -> Array:
	if enemies.is_empty(): return tiles
	tiles = tiles.duplicate()
	var tiles_to_distance: Dictionary = {}
	for OtherTile: TileGD in tiles:
		var distance: int = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), OtherTile.getCoords())).min()
		tiles_to_distance[OtherTile] = distance
			
	tiles.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_distance[x] < tiles_to_distance[y])
	return tiles
#endregion

func onCanCreateInspectScreen() -> bool: return false

func setFieldInfoVisible(state: bool) -> void: # Access via action
	BossFieldInfo.visible = state
