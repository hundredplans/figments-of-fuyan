class_name HandGD
extends Node

const MAX_HAND_SIZE: int = 10
var energy: int = 0
var energy_cap: int = 5

var Tiles: TilesGD
var LevelMap: Node3D
var Units: UnitsGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var GameState: GameStateGD
var PlayerManager: PlayerManagerGD
var Deck: DeckGD
var Tools: ToolsGD

func onStartPhaseStart() -> void:
	on_change_energy(5)

func onHandPhaseStart() -> void:
	card_selected_index = -1
	if get_children().size() < 4: Deck.on_draw_card()
	setLevelUIEnergy()

func on_playable_cards() -> Array:
	return get_children().filter(on_is_card_playable).map(on_get_child_index)

func on_is_card_playable(hand_card: HandCardGD) -> bool:
	return !hand_card.is_queued_for_deletion() and energy >= hand_card.energy

func on_get_child_index(child: Node) -> int:
	return child.get_index()

func onPlayerPhaseStart() -> void:
	card_selected_index = -1

func on_draw_card(deck_card: DeckCardGD) -> void:
	if get_child_count() < MAX_HAND_SIZE:
		on_create_card(deck_card.id)

func on_create_card(id: int) -> void:
	var card := HandCardGD.new()
	card.name = str(randi())
	card.script = preload("res://scenes/screens/level_map/utility_nodes/hand/hand_card.gd")
	add_child(card)
	
	card.on_create_card(id)
	Tools.onEquipTool(card, randi_range(1, 7), randf() > 0.5)
	LevelUI.onDrawCardAnimation(card)

var card_selected_index: int = -1
func on_card_selected(index: int) -> void:
	card_selected_index = index
	if Units.on_units().size() > 0:
		SpectateCamera.is_spectate_spawn = index != -1
		SpectateCamera.onSpectate("AllySelf")

func on_card_placed(Tile: TileGD) -> void:
	if card_selected_index > -1 and Tile.solid_status == 0:
		var hand_card: HandCardGD = get_child(card_selected_index)
		LevelUI.on_card_placed(card_selected_index)
		on_change_energy(-Helper.getCard(hand_card.id).energy)
		await PlayerManager.on_card_placed(hand_card, Tile)
		hand_card.free()
		card_selected_index = -1

func on_change_energy(delta: int) -> void:
	energy = clamp(energy + delta, 0, energy_cap)
	LevelUI.setEnergy(energy)
	setLevelUIEnergy()
	
func setLevelUIEnergy() -> void:
	LevelUI.playable_cards = on_playable_cards()
	LevelUI.on_set_hand_box_cards_state()
	
func onGainDeathEnergy(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	if AppliedBy.Applier != null and AppliedBy.Applier.team == 0 and Deather.team == 1:
		on_change_energy(Deather.base_card.energy)
