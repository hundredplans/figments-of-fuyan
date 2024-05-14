class_name LevelMapGD
extends Node3D

signal action_lock_changed
var GameState: Node

var LoadedLevel: Node3D
var Tiles: TilesGD
var Lights: LightsGD
var LevelUI: Control

var play_ui: bool = true
var game_phase: String

@onready var GameEffects: GameEffectsGD
@onready var Combat: CombatGD = $Combat
@onready var BaseCards: BaseCardsGD = $BaseCards
@onready var Deck: DeckGD = $Deck
@onready var Hand: HandGD = $Hand
@onready var Units: UnitsGD = $Units
@onready var VFX: VFXGD = $VFX

@onready var SpectateCamera: Node3D = $SpectateCamera	
@onready var Vision: VisionGD = $Vision

func on_set_utility_nodes_paths() -> void:
	var new_children: Array = get_children() + [GameState, Tiles, LevelUI, Lights, self]
	for child in new_children:
		for _child in new_children:
			if child != _child and _child.name in child:
				child[_child.name] = _child

func _ready() -> void:
	on_load_default_world_state()
	on_load_world_history()
	Deck.on_create_deck()
	Deck.on_choose_champion()
	
func on_load_world_history() -> void:
	pass
	
func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/levels/" + GameState.level_info.folder_name + "/loaded_level.tscn").instantiate()
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
			setActionLock("HandRegular")
			Vision.onStartPhaseStart()
			Tiles.on_start_phase_start()
			SpectateCamera.onStartPhaseStart()
			Hand.on_start_phase_start()
			LevelUI.onStartPhaseStart()
			Units.on_start_phase_start()
			VFX.onStartPhaseStart()
		"AfterStartPhase":
			LevelUI.onAfterStartPhaseStart()
			Deck.on_after_start_phase_start()
		"HandPhase":
			setActionLock("HandRegular")
			LevelUI.onHandPhaseStart()
			SpectateCamera.onHandPhaseStart()
			Hand.on_hand_phase_start()
			VFX.onHandPhaseStart()
			LevelUI.UnitStatusOverlord.onHandPhaseStart()
			var skip_hand_phase: bool = on_skip_hand_phase_result()
			if play_ui: LevelUI.on_hand_phase_start(skip_hand_phase)
			if skip_hand_phase: on_advance_game_phase()
		"PlayerPhase":
			setActionLock()
			GameEffects.onPlayerPhaseStart()
			Hand.on_player_phase_start()
			LevelUI.on_player_phase_start()
			VFX.onPlayerPhaseStart()
			Units.on_player_phase_start()
			SpectateCamera.onPlayerPhaseStart()
			Combat.onPlayerPhaseStart()
		"PlayerEndTurnPhase":
			setActionLock("Regular")
			GameEffects.onPlayerEndTurnPhaseStart()
			Units.on_player_end_turn_phase_start()
			LevelUI.on_player_end_turn_phase_start()
			Vision.on_player_end_turn_phase_start()
			SpectateCamera.onPlayerEndTurnPhaseStart()
			on_change_game_phase("AIPhase")
		"AIPhase":
			GameEffects.onAIPhaseStart()
			Units.onAIPhaseStart()
			LevelUI.onAIPhaseStart()
		"AIEndTurnPhase":
			GameEffects.onAIEndTurnPhaseStart()
			Units.onAIEndTurnPhaseStart()
			LevelUI.onAIEndTurnPhaseStart()
			on_change_game_phase("PlayerStartTurnPhase")
		"PlayerStartTurnPhase":
			on_change_game_phase("HandPhase")

func on_advance_game_phase() -> void:
	match game_phase:
		"HandPhase": on_change_game_phase("PlayerPhase")
		"PlayerPhase": on_change_game_phase("PlayerEndTurnPhase")
		"PlayerEndTurnPhase": on_change_game_phase("BOTPhase")
		"BOTPhase": on_change_game_phase("PlayerStartTurnPhase")
		"PlayerStartTurnPhase": on_change_game_phase("HandPhase")

var action_lock: String
func setActionLock(x: String = "") -> void:
	if (x == "UnitActionDisabled" and action_lock == "UnitActionRegular"):
		if Units.unit_actions.is_empty():
			x = ""
			action_lock = x
			action_lock_changed.emit(x)
	elif x != "UnitActionDisabled":
		action_lock = x
		action_lock_changed.emit(x)

func on_skip_hand_phase_result(Tile: TileGD = null) -> bool:
	if game_phase == "HandPhase":
		if Settings.autopass_handphase and Hand.on_playable_cards().is_empty(): return true
		if Tiles.on_is_type_get_tiles("Spawn", "obj")\
		.all(func(x: TileGD): return x == Tile or Units.unit_by_tile_bool(x)):
			LevelUI.onHandPhaseNoSpawnTiles()
			return true
	return false

