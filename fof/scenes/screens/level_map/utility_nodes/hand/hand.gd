class_name HandGD
extends Node

var energy: int = 0

var Heroes: HeroesGD
var LevelMap: LevelMapGD
var Units: UnitsGD
var SpectateCamera: Camera3D
var LevelUI: LevelUIGD
var History: HistoryGD
var GameState: GameStateGD

func on_start_phase_start() -> void:
	on_change_energy(Helper.id_to_dict(Heroes.hid_to_id(GameState.hero_id, GameState.hero_level), "Card").e - 1)

func on_hand_phase_start() -> void:
	on_change_energy(1)
	card_selected_index = -1
	if LevelMap.play_ui:
		LevelUI.on_hand_phase_start(on_playable_cards())

func on_playable_cards() -> Array:
	return get_children().filter(on_is_card_playable).map(on_get_child_index)

func on_is_card_playable(hand_card: HandCardGD) -> bool:
	return energy >= hand_card.energy

func on_get_child_index(child: Node) -> int:
	return child.get_index()

func on_player_phase_start() -> void:
	card_selected_index = -1
	if LevelMap.play_ui:
		LevelUI.on_player_phase_start()

func on_draw_card(deck_card: DeckCardGD) -> void:
	on_create_card(deck_card.id, deck_card.tool_id, deck_card.effects)

func on_create_card(id: int, tool_id: int = 0, effects: Array = []) -> void:
	var card := HandCardGD.new()
	card.name = str(randi())
	card.script = preload("res://scenes/screens/level_map/utility_nodes/hand/hand_card.gd")
	add_child(card)
	
	card.History = History
	card.on_create_card(id, tool_id, effects)
	LevelUI.on_draw_card(card)

var card_selected_index: int = -1
func on_card_selected(index: int) -> void:
	card_selected_index = index
	if index > -1:
		SpectateCamera.on_spectate("Spawn")

func on_card_placed(tile_position: Vector3) -> void:
	if card_selected_index > -1:
		var hand_card: HandCardGD = get_child(card_selected_index)
		LevelUI.on_card_placed(card_selected_index)
		on_change_energy(-Helper.id_to_dict(hand_card.id, "Card").e)
		Units.on_card_placed(hand_card, tile_position)
		hand_card.queue_free()
		card_selected_index = -1
		
		if LevelMap.game_phase == "StartPhase":
			LevelMap.on_change_game_phase("AfterStartPhase")
		
		History.add_to_history(["on_card_placed", tile_position])

func on_change_energy(delta: int) -> void:
	energy += delta
	LevelUI.on_change_energy(energy)
	History.add_to_history(["on_change_energy", delta])
