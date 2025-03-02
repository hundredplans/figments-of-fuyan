class_name BossCardGD extends CardGD

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
	overworld_traits, bounty_kills, boss_datastore)

func onLoadData(data: SavedData) -> void:
	super(data)
	boss_datastore = data.boss_datastore
	if boss_datastore != null: boss_datastore.onLoad()
	setBossIntentByName()
	add_to_group("BossCardsGD")
	
func onFofInit() -> void:
	super()
	onResetBossIntentCooldowns()
	
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is OccupyAction:
			onOccupy(action)
		elif action is ChangeBossPhaseAction:
			onChangeBossPhasePostDelay()
#endregion
	
#region Info Getters
func getAttackFromInfo() -> float:
	return info.getAttack(boss_datastore.phase)
	
func getHealthFromInfo() -> float:
	return info.getHealth(boss_datastore.phase)
	
func getSpeedFromInfo() -> float:
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
	return info.getBossIntents(boss_datastore.phase).getIntents()
	
func getSpeedOrderOverrideFromInfo() -> BossCardInfo.SpeedOrderOverride:
	return info.getSpeedOrderOverride(boss_datastore.phase)
	
func getChangeDelayFromInfo() -> int:
	return info.getChangeDelay(boss_datastore.phase)
#endregion

#region Getters
func getArchetypeEnum(archetype_id: int = getArchetypeFromInfo().id) -> Game.Archetypes:
	return super(archetype_id)
#endregion

#region Updaters
func setTileIntents() -> void:
	pass
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
func getBossIntentByName() -> BossIntent:
	var boss_intents: Array[BossIntent] = getBossIntentsFromInfo()
	for _boss_intent: BossIntent in boss_intents:
		if _boss_intent.name == boss_datastore.boss_intent_name:
			return _boss_intent
	return null
	
func setBossIntent(_boss_intent: BossIntent) -> void:
	boss_intent = _boss_intent

	boss_datastore.boss_intent_name = boss_intent.name
	if BossFieldInfo != null: BossFieldInfo.onUpdateBossIntent()
	
	if Tile != null: setTileIntents()
	else: boss_datastore.setTileIntents(boss_datastore.tile_intents) # When first loading in
	
	
func setBossIntentByName() -> void:
	var _boss_intent: BossIntent = getBossIntentByName()
	setBossIntent(_boss_intent)
	
func onChangeBossIntent(_boss_intents: Array, _enemies: Array, _allies: Array) -> BossIntent: return null
func onResetBossIntentCooldowns() -> void:
	for _boss_intent: BossIntent in getBossIntentsFromInfo():
		boss_datastore.boss_intent_name_to_cooldown[_boss_intent.name] = 0
		
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
			
func onChangeBossPhasePostDelay() -> void:
	var new_attack: int = getAttackFromInfo()
	var new_max_health: int = getHealthFromInfo()
	var new_speed: int = getSpeedFromInfo()
	
	var attack_delta: int = new_attack - attack
	var health_delta: int = 0 if new_max_health == 0 else new_max_health - max_health
	var speed_delta: int = new_speed - speed
	
	var stat_info := StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED], [attack_delta, health_delta, speed_delta])
	onPushAction(StatAction.new(stat_info))
	
	if getModelFromInfo() != null:
		onRemoveModel()
		onCreateModel()
#endregion
