class_name LevelMapGD
extends Node3D

signal action_lock_changed
var GameState: Node

var LoadedLevel: Node3D
var Tiles: TilesGD
var Lights: LightsGD
var LevelUI: Control

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
@onready var StatusManager: StatusManagerGD = $StatusManager
@onready var ActionManager: ActionManagerGD = $ActionManager

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
	
	var references: Array = get_children() + [GameState, Tiles, LevelUI, LevelUI.Console, Lights, ActionManager, self]
	Helper.setUtilityNodesPaths(references)
	add_child(LoadedLevel)
	on_change_game_phase("StartPhase")

var phase_ordering: Dictionary = {
	"StartPhase": ["Tiles", "Vision", "SpectateCamera", "Hand", "Units", "LevelUI", "VFX", "StatusManager"],
	"AfterStartPhase": ["LevelUI", "Deck"],
	"HandPhase": ["SpectateCamera", "Hand", "VFX", "StatusManager", "LevelUI"],
	"PlayerPhase": ["GameEffects", "Hand", "LevelUI", "VFX", "Units", "SpectateCamera", "Combat"],
	"PlayerEndTurnPhase": ["GameEffects", "Units", "LevelUI", "Vision", "StatusManager"],
	"AIPhase": ["Combat", "GameEffects", "Units", "LevelUI", "StatusManager"],
	"AIEndTurnPhase": ["GameEffects", "Units", "StatusManager"]
}
func onTriggerPhaseStart(phase: String) -> void:
	var nodes: Array = phase_ordering[phase].map(func(x: String): \
	return Helper.references[Helper.references.map(func(y: Node): return y.name).find(x)])
	phase = phase.insert(0, "on")
	phase += "Start"
	for node in nodes: node.call(phase)

func on_change_game_phase(phase: String) -> void:
	var dev := preload("res://static/dev/dev.tres")
	game_phase = phase
	onTriggerPhaseStart(phase)
	match phase:
		"StartPhase": setActionLock("HandRegular"); if dev.god_start: on_advance_game_phase()
		"AfterStartPhase":
			if dev.god_start:
				var Unit: UnitGD = await Units.onUnitAwakened(1, 0, [], 0, 0, Tiles.onSpawnTiles()[0])
				Unit.stats("health", 50)
				Unit.stats("attack", 50)
				Unit.stats("speed", 5)
				on_advance_game_phase()
		"PlayerPhase": setActionLock("PlayerPhase")
		"PlayerEndTurnPhase": setActionLock("Regular"); on_advance_game_phase()
		"AIEndTurnPhase": on_advance_game_phase()
			

func on_advance_game_phase() -> void:
	match game_phase:
		"StartPhase": on_change_game_phase("AfterStartPhase")
		"HandPhase": on_change_game_phase("PlayerPhase")
		"PlayerPhase": on_change_game_phase("PlayerEndTurnPhase")
		"PlayerEndTurnPhase": on_change_game_phase("AIPhase")
		"AIPhase": on_change_game_phase("AIEndTurnPhase")
		"AIEndTurnPhase": on_change_game_phase("HandPhase")

var action_lock: String = ""
func setActionLock(x: String = "") -> void:
	var dev := preload("res://static/dev/dev.tres")
	if !dev.remove_action_lock:
		if x == "PlayerPhase":
			if action_lock == "UnitActionRegular": return
			x = ""
			
		if (x == "UnitActionDisabled" and action_lock == "UnitActionRegular"):
			if ActionManager.unit_actions.is_empty():
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

