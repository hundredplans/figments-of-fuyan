class_name LevelGD extends FofGD

const START_HAND_SIZE: int = 4
var timeout: int
var energy: int
var max_energy: int

var level_camera_data: LevelCameraData
var phase: Game.Phases
var enemy_spawn_ids: Array

signal card_finished_moving
signal card_moving
signal energy_changed
signal request_camera_data
signal phase_changed
signal draw_card
signal remove_card
signal awakened

#region Load / Save
func onSave() -> SavedData:
	var data: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("LevelTileObjectsGD"))
	request_camera_data.emit()
	return SavedDataLevel.new(info.id, false, data, timeout, enemy_spawn_ids, getFieldCards(), phase, level_camera_data, energy, max_energy)

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
		if TileObject is TileGD: TileObject.add_to_group("LevelTilesGD")
		elif TileObject is ObjectGD: TileObject.add_to_group("LevelObjectsGD")
			
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLoadDataLevel()
	
	for card_data in data.field_cards_data: SavedData.onLoadModel(card_data, self)
	for Card in get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.Tile = Game.getTile(Card.coords)
		Card.onAwaken()
	
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
		
		var spawns: Array = get_tree().get_nodes_in_group("EnemySpawnsGD")
		for i in range(enemy_spawn_ids.size()):
			if enemy_spawn_ids[i] > 0:
				var Card: CardGD = SavedData.onLoadModel(SavedDataCard.new(enemy_spawn_ids[i], true, Vector4i.ZERO, 0, false, false, 1), self)
				onPushAction(AwakenAction.new(Card, spawns[i].getTile()))
				
		onPushAction(LevelVisibleAction.new(false, get_tree().get_nodes_in_group("LevelTileObjectsGD") + get_tree().get_nodes_in_group("FieldCardsGD")))
		return
		
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
		elif action is MovementAction:
			card_moving.emit(action.Card)
		elif action is MovementFinishAction:
			card_finished_moving.emit(action.Card)
	else:
		if action is ChangePhaseAction:
			if action.phase == phase: action.failed = true
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
		Game.Phases.PLAYER: new_phase = Game.Phases.AI
		_: new_phase = Game.Phases.NULL
		
	if new_phase != Game.Phases.NULL:
		onAppendAction(ChangePhaseAction.new(new_phase))
