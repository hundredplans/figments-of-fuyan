class_name LevelGD extends FofGD

const START_HAND_SIZE: int = 3
const AI_TURNS_UNTIL_ADVENTURER: int = 10
const CARD_PLACED_SPECTATE_DELAY: float = 1.0
const DRAW_BELOW_HAND_SIZE: int = 3

var energy: int
var max_energy: int
var level_camera_data: LevelCameraData
var phase: Game.Phases
var enemy_cards: Array
var fight_type: Game.FightTypes
var is_ended: bool
var rewards: Rewards
var anti_boons: Array
var save_file: SaveFileGD
var old_player_vision: Array
var speed_order: SpeedOrder
var player_card_last_seen_turn: int # Default -1 which means they were never seen, if this is > 10 or -1 every enemy has the adventurer tag
var level_area_datastore: LevelAreaDatastore # Specific to each areao
var recent_camera_position: Vector3 # Not saved
var spawn_group: int
var curse_id: int
var level_preview: LevelPreview
var env: Environment

signal set_spectate_card
signal energy_changed
signal request_camera_data
signal request_camera_position_update
signal phase_changed
signal awakened
signal death
signal turn_state_changing
signal camera_change_action
signal active_effect_used
signal active_effect_added
signal tile_occupied
signal set_rewards # Signal for area to interpret
signal game_started
signal game_started_post
signal game_ended
signal rewards_finished # Signal for area to interpret
signal tool_removed
signal update_active_effects
signal camera_change_pre
signal spectate_group
signal set_last_ally_spectate_object
signal vision_changed
signal load_env

#region Load / Save
func onSave() -> SavedData:
	var data: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("LevelTileObjectsGD"))
	request_camera_data.emit()
	
	if rewards != null: rewards.onSave()
	if speed_order != null: speed_order.onSave()
	var old_player_vision_public_ids: Array = old_player_vision.map(func(x: GameObjectGD): return x.public_id)
	
	return SavedDataLevel.new(info.id, false, public_id, data, enemy_cards, getFieldCardDatas(), phase, level_camera_data, energy, max_energy,\
		fight_type, is_ended, rewards, anti_boons, old_player_vision_public_ids, player_card_last_seen_turn, level_area_datastore, speed_order, spawn_group,\
		curse_id, level_preview, env)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("LevelsGD")
	Game.onResetCoordsToTile()
	fight_type = data.fight_type
	energy = data.energy
	max_energy = data.max_energy
	enemy_cards = data.enemy_cards
	speed_order = data.speed_order
	spawn_group = data.spawn_group
	curse_id = data.curse_id
	player_card_last_seen_turn = data.player_card_last_seen_turn
	level_preview = data.level_preview
	env = data.env
	
	for light in info.lights:
		add_child(light.instantiate())
	
	for tile_object_data in data.data:
		onLoadTileObjectInit(tile_object_data)
			
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLoadDataLevel()
	
	for card_data in data.field_cards_data:
		SavedData.onLoadModel(card_data, self)
		
	for Card in get_tree().get_nodes_in_group("CardsGD"):
		Card.onLoadDataLevel()
	
	is_ended = data.is_ended
	
	anti_boons = data.anti_boons
	level_area_datastore = data.level_area_datastore

	level_camera_data = data.level_camera_data
	old_player_vision = data.old_player_vision.map(func(x: int): return Game.onFindPublicIDObject(x))
	
	rewards = data.rewards
	if rewards != null:
		rewards.setInfo(self)
		rewards.onLoad()
		
	if speed_order != null:
		speed_order.onLoad()
		
	if is_ended:
		onGameEnded()

func onLoadTileObjectInit(data: SavedDataTileObject) -> TileObjectGD:
	if data is SavedDataObject and (!data.groups.is_empty() and spawn_group not in data.groups): return null
		
	var TileObject: TileObjectGD = SavedData.onLoadModel(data, self)
	TileObject.add_to_group("LevelTileObjectsGD")
	TileObject.set_spectate_card.connect(func(x: TileObjectGD): set_spectate_card.emit(x))
	
	if TileObject is TileGD:
		TileObject.add_to_group("LevelTilesGD")
		Game.onAddToCoordsToTile(TileObject)
	elif TileObject is ObjectGD:
		TileObject.add_to_group("LevelObjectsGD")
		if TileObject is IObjectGD:
			TileObject.add_to_group("LevelIObjectsGD")
			
	return TileObject

func onLoadActiveLevel(data: SavedDataLevel, _save_file: SaveFileGD) -> void:
	# Triggers after UI and World have loaded
	save_file = _save_file
	energy_changed.emit(energy)
	
	if isEpic() and !is_ended:
		onPushAction(PlayMusicAction.new(Game.getArea().info.boss_music))
		
	if is_init:
		var actions: Array = [StartGameAction.new(), ChangePhaseAction.new(Game.Phases.START)]
		speed_order = SpeedOrder.new()
		for GameObject in get_tree().get_nodes_in_group("GameObjectsGD"):
			GameObject.onLoadDataLevelFofInit()
			
		for AllySpawn: SpawnGD in get_tree().get_nodes_in_group("AllySpawnsGD"):
			var revealed_datastore := Game.onCreateRevealedDatastore(AllySpawn, 0)
			actions.append(RevealAction.new(AllySpawn, revealed_datastore))
			
		for card_data in enemy_cards:
			actions.append(AwakenAction.new(SavedData.onLoadModel(card_data, self), Game.getTile(card_data.coords)))
		
		level_area_datastore = onCreateLevelAreaDatastore()
		
		if curse_id > 0: onPushAction(AddBoonAction.new(curse_id))
		
		var deck_cards: Array = Game.get_tree().get_nodes_in_group("DeckCardsGD")
		deck_cards.shuffle()
		for i in range(deck_cards.size()):
			deck_cards[i].draw_order = i
		
		actions.append(ChangeEnvironmentAction.new(Game.getArea().getEnvironmentFromInfo(isElite())))
		onPushAction(actions)
		return
		
	for Card in get_tree().get_nodes_in_group("HandCardsGD"):
		onPushAction(HandCardAction.new(Card))
		
	onChangePhase(data.phase, true)
	if is_ended:
		onGameEnded()
		
	load_env.emit(env)

var is_init: bool = false
func onFofInit() -> void:
	is_init = true
	var tile_position_to_tile: Dictionary = getTilePositionToTile()
	for Obj in get_tree().get_nodes_in_group("LevelObjectsGD"):
		setOccupiedTiles(Obj, tile_position_to_tile)
	
func getTilePositionToTile() -> Dictionary:
	var tile_position_to_tile: Dictionary
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		tile_position_to_tile[Tile.position] = Tile
	return tile_position_to_tile
	
func setOccupiedTiles(Obj: ObjectGD, tile_position_to_tile: Dictionary = getTilePositionToTile()) -> void:
	Obj.setOccupiedTiles(tile_position_to_tile)
	
#endregion

#region Getters
func getFieldCardDatas() -> Array:
	return SavedData.onSaveGroup((get_tree().get_nodes_in_group("FieldCardsGD") + get_tree().get_nodes_in_group("GraveyardCardsGD"))\
		.filter(func(x: CardGD): return x.isEnemy(0)))
#endregion

#region Setters
func onChangePhase(_phase: Game.Phases, instant: bool = false) -> void:
	var old_phase: Game.Phases = phase
	match old_phase:
		Game.Phases.START:
			onDrawStarterHand()
			setAlliesTurnState(Game.TurnStates.INACTIVE)
			
	phase = _phase
	phase_changed.emit(phase, old_phase, instant)
	
	if phase in Game.ADVANCE_PHASES:
		onAdvanceTurn(Game.ADVANCE_PHASES.find(phase))
	
	match phase:
		Game.Phases.START:
			onForceAction(InsertAction.new(Game.getSaveFile().getChampionCard()))
		Game.Phases.HAND:
			if get_tree().get_node_count_in_group("HandCardsGD") < DRAW_BELOW_HAND_SIZE:
				onForceAction(DrawAction.new())
			if isEpic() and old_phase != Game.Phases.START: # Gain energy per turn for bosses
				onForceAction(EnergyAction.new(Game.getArea().getWorldDifficulty()))
			onCheckSkipHandPhase()
		Game.Phases.AI: onAppendAction(AITurnStartAction.new(1))
		Game.Phases.NEUTRAL: onAppendAction(AITurnStartAction.new(2))
			
	
func setAlliesTurnState(turn_state: Game.TurnStates) -> void:
	for Card in Game.getAllyUnits():
		onPushAction(ChangeTurnStateAction.new(Card, turn_state))
#endregion

#region Action Processing
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is AwakenAction:
			onCardAwakened(action)
		elif action is ChangeEnvironmentAction:
			env = action.environment
		elif action is FinishAwakenAction:
			onCheckSkipHandPhase()
			onCardFinishedAwakening(action)
		elif action is EnergyAction:
			energy = min(action.delta + energy, max_energy)
			energy_changed.emit(energy, action)
			onCheckSkipHandPhase()
		elif action is ChangeTurnStateAction:
			turn_state_changing.emit(action.Card, action)
		elif action is ActiveEffectUsedAction:
			active_effect_used.emit(action.ActiveEffect)
			onRecalculateAITurn(action.Card)
		elif action is AddActiveEffectAction:
			active_effect_added.emit(action.active_effect)
		elif action is OccupyAction:
			tile_occupied.emit(action.Card, action.Tile)
			onRecalculateAITurnOccupy(action, action.Card)
		elif action is EndGameAction and !is_ended:
			setRewards(action.team != 0)
		elif action is StatAction:
			if action.owner == null or action.owner is not MoveToTileAction:
				onRecalculateAITurn(action.getCards(), true, true, false, true)
		elif action is AddToolAction:
			onRecalculateAITurn(action.Card, true, false, false, true)
		elif action is RemoveToolAction:
			onRecalculateAITurn(action.Card, true, false, false, true)
			tool_removed.emit()
		elif action is LevelVisibleAction:
			vision_changed.emit()
		#elif action is VisionAction:
			#vision_changed.emit()
		elif action is VisionNewUnitAction:
			if action.enter_vision:
				if action.Discoverer.isEnemy(action.Discovered.team):
					onRecalculateAITurn(action.Discoverer, true, true)
				
				if action.Discoverer.isAlly(1) and action.Discovered.isAlly(0):
					onPlayerCardSpottedByAI()
					
				if phase == Game.Phases.PLAYER and action.Discoverer.isAlly(0) and action.Discovered.isEnemy(0) and action.Discovered not in action.old_player_vision:
					onRemoveMoveAndAttackActions(action.Discoverer)
				
		elif action is DeathAction:
			onRecalculateAITurn(action.Defender, true, true, true, true)
			speed_order.onDeath(action.Defender)
			death.emit(action.Defender)
		elif action is ChangeActiveEffectChargesAction:
			update_active_effects.emit()
		elif action is ClearTileObjectAction:
			update_active_effects.emit()
		elif action is CameraSpectateGroupAction:
			spectate_group.emit(action.team)
		elif action is RevealAction:
			if action.Revealed is CardGD and action.Revealed != null and action.Revealed.isAlly(0):
				onPlayerCardSpottedByAI()
		elif action is StartGameAction:
			if action.getDelay() == 0: return
			game_started_post.emit()
	elif !action.post:
		if action is ChangePhaseAction:
			if action.phase == phase: action.onFailAction(); return
			onChangePhase(action.phase)
		elif action is CameraChangeAction:
			if action.SpectateObject != null and getSpectateObject() == action.SpectateObject:
				action.onFailAction()
			else:
				camera_change_pre.emit(action.SpectateObject, getSpectateObject())
		elif action is MovementFinishAction:
			action.setPhaseByLevel(phase)
		elif action is StartGameAction:
			if action.getDelay() == 0: return # Means admin is on
			game_started.emit()
#endregion

#region Hand
func onDrawStarterHand() -> void:
	var draw_count: int = START_HAND_SIZE
	
	for __ in range(draw_count):
		onForceAction(DrawAction.new())
		
func onCheckSkipHandPhase() -> void:
	var hand: Array = get_tree().get_nodes_in_group("HandCardsGD")
	var is_hand_playable: bool = hand.any(func(x: CardGD): return x.isPlayable(energy))
	var are_spawns_occupied: bool = get_tree().get_nodes_in_group("AllySpawnsGD").all(func(x: SpawnGD): return x.isSpawnOccupied())
	
	if phase == Game.Phases.HAND and (hand.is_empty() or !is_hand_playable or are_spawns_occupied):
		onAppendAction(ChangePhaseAction.new(Game.Phases.PLAYER))
#endregion

#region Pass Turn
func onPassTurn() -> void:
	var new_phase: Game.Phases
	match phase:
		Game.Phases.HAND: new_phase = Game.Phases.PLAYER
		Game.Phases.PLAYER:
			var ally_units: Array = Game.getAllyUnits(0)
			var Card: CardGD = getAllySpectateObject()
			#for AllyCard in ally_units:
				#if AllyCard.turn_state == Game.TurnStates.ACTIVE and Card == AllyCard:
					#onPushAction(ChangeTurnStateAction.new(AllyCard, Game.TurnStates.PASSED))
					#if !ally_units.all(func(x: CardGD): return x.turn_state == Game.TurnStates.PASSED):
						#return
		
			if Card != null and Card.turn_state != Game.TurnStates.PASSED:
				onPushAction(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))
				if !ally_units.all(func(x: CardGD): return x.turn_state == Game.TurnStates.PASSED):
					onSpectateClosestAlly(Card)
					return
				
			new_phase = Game.Phases.AI
		_: new_phase = Game.Phases.NULL
		
	if new_phase != Game.Phases.NULL:
		onAppendAction(ChangePhaseAction.new(new_phase))
		
func getPhase() -> Game.Phases:
	return phase
#endregion

#region SpectateCard
func setTileObjectSpectateCard(TileObject: TileObjectGD, SpectateCard: CardGD) -> void:
	TileObject.SpectateCard = SpectateCard
#endregion

#region Camera
var SpectateObject: GameObjectGD
func getSpectateObject() -> GameObjectGD:
	return SpectateObject
	
func getAllySpectateObject() -> CardGD:
	if SpectateObject != null and SpectateObject is CardGD and SpectateObject.isAlly(0) and SpectateObject.card_place == Game.CardPlaces.FIELD: return SpectateObject
	return null
	
func onCameraChange(action: CameraChangeAction) -> void:
	camera_change_action.emit(action.SpectateObject, getSpectateObject())
	SpectateObject = action.SpectateObject
	
func onRequestCameraPositionUpdate() -> void:
	request_camera_position_update.emit()
	
func onSpectateClosestAlly(Card: CardGD) -> void:
	var unpassed_allies: Array = Game.getAllyUnits(0).filter(func(x: CardGD): return x.turn_state != Game.TurnStates.PASSED)
	if unpassed_allies.is_empty(): return
	var coords: Vector4i = Card.getCoords()
	unpassed_allies.sort_custom(func(x: CardGD, y: CardGD):\
		return Game.getCoordsDistance(coords, x.getCoords()) < Game.getCoordsDistance(coords, y.getCoords()))
	onPushAction(CameraChangeAction.new(unpassed_allies[0]))
#endregion

#region Game Ended
func setRewards(is_win: bool) -> void:
	onPushAction(PlayMusicAction.new(null))
	is_ended = true
	set_rewards.emit(is_win)

func onGameEnded() -> void:
	for FofObject in get_tree().get_nodes_in_group("FofGD"):
		FofObject.onLevelEnded(rewards != null)
	
	game_ended.emit(rewards)
	
func isGameEnded() -> bool:
	return is_ended
	
func onRewardsFinished() -> void:
	rewards_finished.emit(save_file)
#endregion

#region AI
var ai_turn_recalculated: bool
func onRecalculateAITurn(cards: Variant, include_self: bool = true, include_enemies: bool = false, include_allies: bool = false, in_vision: bool = true) -> void:
	if cards == null: return
	if cards is CardGD: cards = [cards]
	
	var finish_action: MovementFinishAction = Game.ActionManagerReference.onFindFirstAction(MovementFinishAction)
	if finish_action == null or !finish_action.Card.isEnemy(0): return
	
	var AICard: CardGD = finish_action.Card
	if !cards.any(isCardValidForRecalculateAITurn.bind(AICard, include_self, include_enemies, include_allies, in_vision)): return
	
	onRemoveMoveAndAttackActions(AICard)
	finish_action.setRetryAiTurn(true)
			
func isCardValidForRecalculateAITurn(Card: CardGD, AICard: CardGD, include_self: bool, include_enemies: bool, include_allies: bool, in_vision: bool):
	if Card == AICard and include_self: return true
	if AICard.isEnemy(Card.team) and include_enemies and (!in_vision or Card in AICard.getVisibleFieldCardsEnemies()): return true
	if AICard.isAlly(Card.team) and include_allies and (!in_vision or Card in AICard.getVisibleFieldCardsAllies()): return true
	return false
			
func onRecalculateAITurnOccupy(action: OccupyAction, Card: CardGD) -> void:
	var finish_action: Action = Game.ActionManagerReference.onFindFirstAction(MovementFinishAction)
	
	if finish_action == null or !finish_action.Card.isEnemy(0): return
	if finish_action.Card != Card: return
	
	if Card.ai_datastore.onCheckDoubleAdjacentAndReceiving(Card)\
		or (action.owner != null and action.owner is not MoveToTileAction)\
		or Card.onAICheckActiveEffectsOnlyDFL(Card.ai_datastore.DFL, finish_action):
			
		onRemoveMoveAndAttackActions(Card)
		finish_action.setRetryAiTurn(true)
#endregion

#region Player Card Last Seen Turn
func isAIAdventurerArchetypeGlobal() -> bool:
	return player_card_last_seen_turn == -1 or player_card_last_seen_turn >= AI_TURNS_UNTIL_ADVENTURER

func onAdvanceTurn(team: int) -> void:
	if team != 1 or player_card_last_seen_turn == -1: return
	player_card_last_seen_turn += 1
		
func onPlayerCardSpottedByAI() -> void:
	player_card_last_seen_turn = 0
#endregion

#region Level Area Datastore
func onCreateLevelAreaDatastore() -> LevelAreaDatastore:
	#assert(false)
	return null
#endregion

#region Awakened
func onCardAwakened(action: AwakenAction) -> void:
	awakened.emit(action.Card)
	speed_order.onAwaken(action.Card)
	if phase == Game.Phases.START and action.Card.isAlly(0):
		onAppendAction(ChangePhaseAction.new(Game.Phases.HAND))
	
func onCardFinishedAwakening(action: FinishAwakenAction) -> void:
	if !action.Card.isLevelVisible(): return
	
	if phase == Game.Phases.START:
		onPushAfterAction(CameraChangeAction.new(action.Card), ChangePhaseAction)
		return
		
	var arrive_action: ArriveAction = Game.ActionManagerReference.onFindFirstAction(ArriveAction)
	if action.Card.info.id == 27 and arrive_action != null and arrive_action.Card == action.Card: # Dont play for coco crab arrive
		return
	
	var actions: Array = []
	if !action.override_spectate:
		var spectate_awakened_card_temporarily := CameraChangeAction.new(action.Card)
		spectate_awakened_card_temporarily.setActionDelay(CARD_PLACED_SPECTATE_DELAY)
		actions.append(spectate_awakened_card_temporarily)
	
	if phase == Game.Phases.HAND:
		setLastAllySpectateObject()
		if LastAllySpectateObject == null: return
		
		actions.append(CameraChangeAction.new(LastAllySpectateObject))
		onPushAfterAction(actions, ChangePhaseAction)
		return
		
	if !action.override_spectate:
		actions.append(CameraChangeAction.new(getSpectateObject()))
	onPushAction(actions)
	
var LastAllySpectateObject: CardGD
func setLastAllySpectateObject() -> void:
	set_last_ally_spectate_object.emit()

func getNextAIUnit(inactive_cards: Array, team: int) -> CardGD:
	return speed_order.getNextAIUnit(inactive_cards, team)

func isElite() -> bool:
	return fight_type == Game.FightTypes.ELITE

func isEpic() -> bool:
	return fight_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]

#region Boss
func getBoss() -> EpicCardGD:
	var boss_cards: Array = get_tree().get_nodes_in_group("EpicCardsGD")
	return boss_cards[0] if !boss_cards.is_empty() else null
#endregion

#region UI
var is_action_lock: bool
func onActionLock(state: bool) -> void:
	is_action_lock = state
	
func isActionLock() -> bool:
	return is_action_lock
#endregion
