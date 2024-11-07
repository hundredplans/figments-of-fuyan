class_name LevelGD extends FofGD

const START_HAND_SIZE: int = 4
var timeout: int
var energy: int
var max_energy: int

var level_camera_data: LevelCameraData
var phase: Game.Phases
var enemy_spawn_ids: Array

signal set_spectate_card
signal energy_changed
signal request_camera_data
signal phase_changed
signal draw_card
signal remove_card
signal awakened
signal turn_state_changing
signal camera_change_action
signal active_effect_used
signal active_effect_added
signal boon_added
signal boon_removed
signal boon_activated
signal boon_ascended
signal tile_occupied

#region Load / Save
func onSave() -> SavedData:
	var data: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("LevelTileObjectsGD"))
	request_camera_data.emit()
	return SavedDataLevel.new(info.id, false, public_id, data, timeout, enemy_spawn_ids, getFieldCards(), phase, level_camera_data, energy, max_energy)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	energy = data.energy
	max_energy = data.max_energy
	enemy_spawn_ids = data.enemy_spawn_ids
	
	for light in info.lights:
		add_child(light.instantiate())
	
	for tile_object_data in data.data:
		var TileObject: TileObjectGD = SavedData.onLoadModel(tile_object_data, self)
		TileObject.add_to_group("LevelTileObjectsGD")
		TileObject.set_spectate_card.connect(func(x: TileObjectGD): set_spectate_card.emit(x))
		
		if TileObject is TileGD: TileObject.add_to_group("LevelTilesGD"); 
		elif TileObject is ObjectGD:
			TileObject.add_to_group("LevelObjectsGD")
			if TileObject is IObjectGD:
				TileObject.add_to_group("LevelIObjectsGD")
			
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLoadDataLevel()
	
	for card_data in data.field_cards_data: SavedData.onLoadModel(card_data, self)
	for Card in get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.onLoadDataLevel()
		
	energy_changed.emit(energy)
	level_camera_data = data.level_camera_data
	add_to_group("LevelsGD")

func onLoadActiveLevel(data: SavedDataLevel) -> void:
	# Triggers after UI and World have loaded
	if is_init:
		var deck_cards: Array = get_tree().get_nodes_in_group("AllyCardsGD")
		
		var champion_card: CardGD = deck_cards.filter(func(x: CardGD): return Game.isChampion(x.info.rarity))[0]
		deck_cards.erase(champion_card)
		
		deck_cards = deck_cards.filter(func(x: CardGD): return !x.is_in_group("HandCardsGD"))
		for Card in deck_cards: onPushAction(AddToDeckAction.new(Card, AddToDeckAction.ADD_TYPES.SHUFFLE))
		
		onPushAction(InsertAction.new(champion_card))
		onPushAction(ChangePhaseAction.new(Game.Phases.START))
		
		
		for Spawn in get_tree().get_nodes_in_group("AllySpawnsGD"):
			onPushAction(RevealAction.new(Spawn))
		
		var spawns: Array = get_tree().get_nodes_in_group("EnemySpawnsGD").filter(func(x: SpawnGD): return x.spawn_id == 0)
		for i in range(spawns.size()):
			var Spawn: SpawnGD = spawns[i]
			var Card: CardGD = SavedData.onLoadModel(SavedDataCard.new(enemy_spawn_ids[i], true, 0, Vector4i.ZERO, Spawn.tile_rotation, false, false, 1), self)
			onPushAction(AwakenAction.new(Card, Spawn.getTile()))
				
		for Spawn in get_tree().get_nodes_in_group("NeutralSpawnsGD").filter(func(x: SpawnGD): return x.spawn_id > 0):
			var Card: CardGD = SavedData.onLoadModel(SavedDataCard.new(Spawn.spawn_id, true, 0, Vector4i.ZERO, Spawn.tile_rotation, false, false, 2), self)
			onPushAction(AwakenAction.new(Card, Spawn.getTile()))
		
		var boon_actions: Array = get_tree().get_nodes_in_group("BoonsGD").map(func(x: BoonGD): return AddBoonAction.new(x.info.id, x.ascended, true))
		onPushAction(boon_actions)
				
		onPushAction(LevelVisibleAction.new(false, get_tree().get_nodes_in_group("LevelTileObjectsGD") + get_tree().get_nodes_in_group("FieldCardsGD")))
		return
		
	for Boon in get_tree().get_nodes_in_group("BoonsGD"):
		boon_added.emit(Boon)
	onChangePhase(data.phase, true)
	for Card in get_tree().get_nodes_in_group("HandCardsGD"):
		draw_card.emit(Card)
		
	get_tree().call_group("FieldCardsGD", "onUpdateVision")

var is_init: bool = false
func onFofInit() -> void:
	is_init = true
	var tile_position_to_tile: Dictionary
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		tile_position_to_tile[Tile.position] = Tile
	
	get_tree().call_group("ObjectsGD", "setOccupiedTiles", tile_position_to_tile)
#endregion

#region Getters
func getFieldCards() -> Array:
	return SavedData.onSaveGroup(get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return !x.is_in_group("AllyCardsGD")))
#endregion

#region Setters
func onChangePhase(_phase: Game.Phases, instant: bool = false) -> void:
	match phase: # Old phase
		Game.Phases.START:
			onDrawStarterHand()
			setAlliesTurnState(Game.TurnStates.INACTIVE)
		Game.Phases.HAND:
			onCheckSkipHandPhase()
				
	phase = _phase
	phase_changed.emit(phase, instant)
	
	match phase:
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
		elif action is AwakenAction and action.Card.isAlly(0):
			awakened.emit(action.Card)
			if phase == Game.Phases.START: append_action.emit(ChangePhaseAction.new(Game.Phases.HAND))
		elif action is RemoveCardAction:
			remove_card.emit(action.Card)
			onCheckSkipHandPhase()
		elif action is InsertAction:
			draw_card.emit(action.Card)
		elif action is EnergyAction:
			energy += action.energy
			energy_changed.emit(energy)
			onCheckSkipHandPhase()
		elif action is ChangeTurnStateAction:
			turn_state_changing.emit(action.Card)
		elif action is CameraChangeAction:
			onCameraChange(action)
		elif action is ActiveEffectUsedAction:
			active_effect_used.emit(action.ActiveEffect)
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
	else:
		if action is ChangePhaseAction:
			if action.phase == phase: action.failed = true
		elif action is CameraChangeAction:
			if getSpectateObject() == action.SpectateObject: action.failed = true
#endregion

#region Hand
func onDrawStarterHand() -> void:
	var hand_cards: Array = get_tree().get_nodes_in_group("HandCardsGD")
	if hand_cards.size() > START_HAND_SIZE: hand_cards.resize(START_HAND_SIZE)
	var draw_count: int = START_HAND_SIZE - hand_cards.size() 
	
	for Card in hand_cards:
		onPushAction(InsertAction.new(Card))
	
	for __ in range(draw_count):
		onPushAction(DrawAction.new())
		
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
#endregion
