class_name HandGD
extends Node

const MAX_HAND_SIZE: int = 10
var energy: int = 0
var energy_cap: int = 0

var Tiles: TilesGD
var Heroes: HeroesGD
var LevelMap: Node3D
var Units: UnitsGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var GameState: GameStateGD

func on_start_phase_start() -> void:
	on_change_energy(Helper.id_to_dict(Heroes.hid_to_id(GameState.hero_id, GameState.hero_level), "Card").e - 1)

func on_hand_phase_start() -> void:
	card_selected_index = -1
	on_change_energy(1)

func on_playable_cards() -> Array:
	return get_children().filter(on_is_card_playable).map(on_get_child_index)

func on_is_card_playable(hand_card: HandCardGD) -> bool:
	return energy >= hand_card.energy

func on_get_child_index(child: Node) -> int:
	return child.get_index()

func on_player_phase_start() -> void:
	card_selected_index = -1

func on_draw_card(deck_card: DeckCardGD) -> void:
	if get_child_count() < MAX_HAND_SIZE:
		on_create_card(deck_card.id, deck_card.tool_id, deck_card.effects)

func on_create_card(id: int, tool_id: int = 0, effects: Array = []) -> void:
	var card := HandCardGD.new()
	card.name = str(randi())
	card.script = preload("res://scenes/screens/level_map/utility_nodes/hand/hand_card.gd")
	add_child(card)
	
	card.on_create_card(id, tool_id, effects)
	energy_cap = max(Helper.id_to_dict(id, "Card").e, energy_cap)
	LevelUI.on_draw_card(card)

var card_selected_index: int = -1
func on_card_selected(index: int) -> void:
	card_selected_index = index
	if Units.on_units().size() > 0: SpectateCamera.onSpectate("Spawn" if index > -1 else "Ally")

func on_card_placed(Tile: TileGD) -> void:
	if card_selected_index > -1 and Tile.solid_status == 0:
		var hand_card: HandCardGD = get_child(card_selected_index)
		LevelUI.on_card_placed(card_selected_index)
		on_change_energy(-Helper.id_to_dict(hand_card.id, "Card").e)
		Units.PlayerManager.on_card_placed(hand_card, Tile)
		hand_card.queue_free()
		card_selected_index = -1
		
		if LevelMap.game_phase == "StartPhase":
			LevelMap.on_change_game_phase("AfterStartPhase")

func on_change_energy(delta: int) -> void:
	energy = clamp(energy + delta, 0, energy_cap)
	LevelUI.on_change_energy(energy, energy == energy_cap)
	LevelUI.playable_cards = on_playable_cards()
	LevelUI.on_set_hand_box_cards_state()
