class_name LevelMapGD
extends Node3D
var GameState: Node

var LoadedLevel: Node3D
var Tiles: TilesGD
var Lights: LightsGD
var LevelUI: Control

var play_ui: bool = true
var game_phase: String

@onready var BaseCards: BaseCardsGD = $BaseCards
@onready var Heroes: HeroesGD = $Heroes
@onready var Deck: DeckGD = $Deck
@onready var Hand: HandGD = $Hand
@onready var History: HistoryGD = $History
@onready var Units: UnitsGD = $Units

@onready var SpectateCamera: Camera3D = $SpectateCamera
@onready var Vision: Node3D = $Vision

func on_set_utility_nodes_paths() -> void:
	var new_children: Array = get_children() + [GameState, Tiles, LevelUI, Lights, self]
	for child in new_children:
		for _child in new_children:
			if child != _child and _child.name in child:
				child[_child.name] = _child

func _ready() -> void:
	on_load_default_world_state()
	History.on_load_world_history()
	Vision.on_recalculate_vision()
	Deck.on_create_deck()
	Deck.on_choose_champion()

func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/" + GameState.level_info.bgfn + "/loaded_level.tscn").instantiate()
	LoadedLevel.script = null
	
	LoadedLevel.get_node("Tiles").script = preload("res://scenes/screens/level_map/utility_nodes/tiles/tiles.gd")
	LoadedLevel.get_node("Lights").script = preload("res://scenes/screens/level_map/utility_nodes/lights/lights.gd")
	Tiles = LoadedLevel.get_node("Tiles")
	Lights = LoadedLevel.get_node("Lights")
	
	on_set_utility_nodes_paths()
	
	add_child(LoadedLevel)
	on_change_game_phase("StartPhase")
	
func on_change_game_phase(phase: String) -> void:
	game_phase = phase
	match phase:
		"StartPhase":
			SpectateCamera.on_spectate("Spawn")
			Hand.on_start_phase_start()
		"AfterStartPhase": 
			Deck.on_after_start_phase_start()
		"HandPhase":
			SpectateCamera.on_spectate("Spawn")
			Hand.on_hand_phase_start()
		"PlayerPhase":
			Hand.on_player_phase_start()
			Units.on_player_phase_start()
			SpectateCamera.on_spectate("Unit")
		"PlayerEndTurnPhase":
			LevelUI.on_player_end_turn_phase_start()
		"BOTPhase":
			pass
		"PlayerStartTurnPhase":
			pass
	
	History.add_to_history(["on_change_game_phase", phase])

func on_advance_game_phase() -> void:
	match game_phase:
		"HandPhase": on_change_game_phase("PlayerPhase")
		"PlayerPhase": on_change_game_phase("PlayerEndTurnPhase")
		"PlayerEndTurnPhase": on_change_game_phase("BOTPhase")
		"BOTPhase": on_change_game_phase("PlayerStartTurnPhase")
		"PlayerStartTurnPhase": on_change_game_phase("HandPhase")
