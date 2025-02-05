class_name LevelGD extends FofGD

const START_HAND_SIZE: int = 4
const AI_TURNS_UNTIL_ADVENTURER: int = 10
const CARD_PLACED_SPECTATE_DELAY: float = 1.0

var energy: int
var max_energy: int
var level_camera_data: LevelCameraData
var phase: Game.Phases
var enemy_spawns: Array
var is_ended: bool
var is_elite: bool
var rewards: Rewards
var anti_boons: Array
var save_file: SaveFileGD
var old_player_vision: Array
var player_card_last_seen_turn: int # Default -1 which means they were never seen, if this is > 10 or -1 every enemy has the adventurer tag
var level_area_datastore: LevelAreaDatastore # Specific to each areao
var recent_camera_position: Vector3 # Not saved

signal set_spectate_card
signal energy_changed
signal request_camera_data
signal request_camera_position_update
signal phase_changed
signal draw_card
signal remove_card
signal awakened
signal death
signal turn_state_changing
signal camera_change_action
signal active_effect_used
signal active_effect_added
signal boon_added
signal boon_removed
signal boon_activated
signal boon_ascended
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

#region Load / Save
func onSave() -> SavedData:
	var data: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("LevelTileObjectsGD"))
	request_camera_data.emit()
	
	if rewards != null: rewards.onSave()
	var old_player_vision_public_ids: Array = old_player_vision.map(func(x: GameObjectGD): return x.public_id)
	
	return SavedDataLevel.new(info.id, false, public_id, data, enemy_spawns, getFieldCards(), phase, level_camera_data, energy, max_energy,\
 	is_elite, is_ended, rewards, anti_boons, old_player_vision_public_ids, player_card_last_seen_turn, level_area_datastore)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	energy = data.energy
	max_energy = data.max_energy
	enemy_spawns = data.enemy_spawns
	
	for light in info.lights:
		add_child(light.instantiate())
	
	for tile_object_data in data.data:
		onLoadTileObjectInit(tile_object_data)
			
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLoadDataLevel()
	
	for card_data in data.field_cards_data: SavedData.onLoadModel(card_data, self)
	for Card in get_tree().get_nodes_in_group("CardsGD"):
		Card.onLoadDataLevel()
	
	is_elite = data.is_elite
	is_ended = data.is_ended
	
	anti_boons = data.anti_boons
	level_area_datastore = data.level_area_datastore

	level_camera_data = data.level_camera_data
	old_player_vision = data.old_player_vision.map(func(x: int): return Game.onFindPublicIDObject(x))
	add_to_group("LevelsGD")
	
	rewards = data.rewards
	if rewards != null:
		rewards.setInfo(self)
		rewards.onLoad()
		
	if is_ended:
		onGameEnded()

func onLoadTileObjectInit(data: SavedDataTileObject) -> TileObjectGD:
	var TileObject: TileObjectGD = SavedData.onLoadModel(data, self)
	TileObject.add_to_group("LevelTileObjectsGD")
	TileObject.set_spectate_card.connect(func(x: TileObjectGD): set_spectate_card.emit(x))
	
	if TileObject is TileGD: TileObject.add_to_group("LevelTilesGD"); 
	elif TileObject is ObjectGD:
		TileObject.add_to_group("LevelObjectsGD")
		if TileObject is IObjectGD:
			TileObject.add_to_group("LevelIObjectsGD")
			
	return TileObject

func onLoadActiveLevel(data: SavedDataLevel, _save_file: SaveFileGD) -> void:
	# Triggers after UI and World have loaded
	save_file = _save_file
	energy_changed.emit(energy)
	if is_init:
		var actions: Array = [StartGameAction.new(), ChangePhaseAction.new(Game.Phases.START)]
		for GameObject in get_tree().get_nodes_in_group("GameObjectsGD"):
			GameObject.onLoadDataLevelFofInit()
			
		for card_data in enemy_spawns:
			actions.append(AwakenAction.new(SavedData.onLoadModel(card_data, self), Game.getTile(card_data.coords)))
		
		actions += get_tree().get_nodes_in_group("BoonsGD").map(func(x: BoonGD): return AddBoonAction.new(x.info.id, x.ascended, true))
		level_area_datastore = onCreateLevelAreaDatastore()
		onPushAction(actions)
		return

	for Boon in get_tree().get_nodes_in_group("BoonsGD"):
		boon_added.emit(Boon)
		
	for Card in get_tree().get_nodes_in_group("HandCardsGD"):
		draw_card.emit(Card)
		
	onChangePhase(data.phase, true)
	#onPushAction(VisionAction.new(get_tree().get_nodes_in_group("FieldCardsGD")))
	if is_ended:
		onGameEnded()

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
func getFieldCards() -> Array:
	return SavedData.onSaveGroup(get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return !x.is_in_group("AllyCardsGD")))
#endregion

#region Setters
func onChangePhase(_phase: Game.Phases, instant: bool = false) -> void:
	var old_phase: Game.Phases = phase
	match phase: # Old phase
		Game.Phases.START:
			onDrawStarterHand()
			setAlliesTurnState(Game.TurnStates.INACTIVE)
			
	phase = _phase
	phase_changed.emit(phase, old_phase, instant)
	
	if phase in Game.ADVANCE_PHASES:
		onAdvanceTurn(Game.ADVANCE_PHASES.find(phase))
	
	match phase:
		Game.Phases.HAND:
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
		if action is ChangePhaseAction: onChangePhase(action.phase)
		elif action is DrawAction: draw_card.emit(action.Card)
		elif action is AwakenAction:
			onCardAwakened(action)
		elif action is FinishAwakenAction:
			onCheckSkipHandPhase()
			onCardFinishedAwakening(action)
		elif action is RemoveCardAction:
			remove_card.emit(action.Card)
		elif action is InsertAction:
			draw_card.emit(action.Card)
		elif action is EnergyAction:
			energy = min(action.energy + energy, max_energy)
			energy_changed.emit(energy)
			onCheckSkipHandPhase()
		elif action is ChangeTurnStateAction:
			turn_state_changing.emit(action.Card, action)
		elif action is CameraChangeAction:
			onCameraChange(action)
		elif action is ActiveEffectUsedAction:
			active_effect_used.emit(action.ActiveEffect)
			onRecalculateAITurn(action.Card)
		elif action is AddActiveEffectAction:
			active_effect_added.emit(action.active_effect)
		elif action is AddBoonAction:
			boon_added.emit(action.Boon)
		elif action is RemoveBoonAction:
			boon_removed.emit(action.id)
		elif action is BoonActivatedAction:
			boon_activated.emit(action.Boon)
		elif action is ChangeBoonAscenscionAction:
			boon_ascended.emit(action.Boon)
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
		elif action is VisionNewUnitAction:
			if action.enter_vision:
				if action.Discoverer.isEnemy(action.Discovered.team):
					onRecalculateAITurn(action.Discoverer, true)
				
				if action.Discoverer.isAlly(1) and action.Discovered.isAlly(0):
					onPlayerCardSpottedByAI()
					
				if phase == Game.Phases.PLAYER and action.Discoverer.isAlly(0) and action.Discovered.isEnemy(0) and action.Discovered not in action.old_player_vision:
					onRemoveMoveAndAttackActions(action.Discoverer)
				
		elif action is DeathAction:
			onRecalculateAITurn(action.Defender, true, true, true, true)
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
	else:
		if action is ChangePhaseAction:
			if action.phase == phase: action.onFailAction()
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
	var hand_cards: Array = get_tree().get_nodes_in_group("HandCardsGD")
	if hand_cards.size() > START_HAND_SIZE: hand_cards.resize(START_HAND_SIZE)
	var draw_count: int = START_HAND_SIZE - hand_cards.size() 
	
	for Card in hand_cards:
		onForceAction(InsertAction.new(Card))
	
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
#endregion

#region Game Ended
func setRewards(is_win: bool) -> void:
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
	assert(false)
	return null
#endregion

#region Awakened
func onCardAwakened(action: AwakenAction) -> void:
	awakened.emit(action.Card)
	if phase == Game.Phases.START and action.Card.isAlly(0):
		onAppendAction(ChangePhaseAction.new(Game.Phases.HAND))
		
	
func onCardFinishedAwakening(action: FinishAwakenAction) -> void:
	if !action.Card.isLevelVisible(): return
	
	if phase == Game.Phases.START:
		onPushAfterAction(CameraChangeAction.new(action.Card), ChangePhaseAction)
		return
	
	var spectate_awakened_card_temporarily := CameraChangeAction.new(action.Card)
	spectate_awakened_card_temporarily.setActionDelay(CARD_PLACED_SPECTATE_DELAY)
	var actions: Array = [spectate_awakened_card_temporarily]
	
	if phase == Game.Phases.HAND:
		setLastAllySpectateObject()
		if LastAllySpectateObject == null: return
		
		actions.append(CameraChangeAction.new(LastAllySpectateObject))
		onPushAfterAction(actions, ChangePhaseAction)
		return
		
	actions.append(CameraChangeAction.new(getSpectateObject()))
	onPushAction(actions)
	
var LastAllySpectateObject: CardGD
func setLastAllySpectateObject() -> void:
	set_last_ally_spectate_object.emit()
