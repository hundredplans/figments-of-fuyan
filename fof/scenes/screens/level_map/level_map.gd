class_name LevelMapGD
extends Node3D

var GameState: Node

var LoadedLevel: Node3D
var Tiles: TilesGD
var Lights: LightsGD
var LevelUI: Control

var turns: int = 0
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
	AudioMaster.onPlayMusic(preload("res://assets/music/BossfightPAlm.wav"))
	
func on_load_world_history() -> void:
	pass
	
func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/levels/" + GameState.save_info.level_info.folder_name + "/loaded_level.tscn").instantiate()
	LoadedLevel.script = null
	
	LoadedLevel.get_node("Tiles").script = preload("res://scenes/screens/level_map/utility_nodes/tiles/tiles.gd")
	LoadedLevel.get_node("Lights").script = preload("res://scenes/screens/level_map/utility_nodes/lights/lights.gd")
	
	Tiles = LoadedLevel.get_node("Tiles")
	Lights = LoadedLevel.get_node("Lights")
	
	var references: Array = get_children() + [GameState, Tiles, LevelUI, LevelUI.Console, Lights, ActionManager, self]
	Helper.setUtilityNodesPaths(references)
	add_child(LoadedLevel)
	onChangeGamePhaseAfterDelay("StartPhase")

var phase_ordering: Dictionary = {
	"StartPhase": ["Tiles", "Vision", "SpectateCamera", "Hand", "Units", "LevelUI", "VFX", "StatusManager", "Boons", "ObjectManager"],
	"AfterStartPhase": ["LevelUI", "Deck"],
	"HandPhase": ["SpectateCamera", "Hand", "VFX", "StatusManager", "LevelUI", "Tools", "Units", "TriggerManager"],
	"PlayerPhase": ["Hand", "LevelUI", "VFX", "SpectateCamera", "Combat", "PlayerManager"],
	"PlayerEndTurnPhase": ["TriggerManager", "LevelUI", "Vision", "StatusManager", "PlayerManager"],
	"AIPhase": ["Combat", "TriggerManager", "Units", "LevelUI", "StatusManager", "Tools", "AIManager"],
	"AIEndTurnPhase": ["TriggerManager", "Units", "StatusManager"],
	"NeutralPhase": ["NeutralManager"],
	"NeutralEndTurnPhase": [],
}
func onTriggerPhaseStart(phase: String) -> void:
	var nodes: Array = phase_ordering[phase].map(func(x: String): \
	return Helper.references[Helper.references.map(func(y: Node): return y.name).find(x)])
	phase = phase.insert(0, "on")
	phase += "Start"
	
	for node in nodes:
		node.call(phase)

var loading_phase: String
var phase_queue: Array = []
func onStartChangePhase(phase: String) -> void:
	loading_phase = phase
	ActionManager.onAddAction(DelayActionGD.new(onChangeGamePhaseAfterDelay.bind(phase), true, DelayGD.new(0.01)), ActionManagerGD.APPEND)
	
func onChangeGamePhaseAfterDelay(phase: String) -> void:
	game_phase = phase
	var dev := preload("res://static/dev/dev.tres")
	onTriggerPhaseStart(phase)
	match phase:
		"StartPhase": if dev.god_start: onStartChangePhase("AfterStartPhase")
		"AfterStartPhase":
			if dev.god_start:
				var Unit: UnitGD = await Units.onUnitAwakened(1, 0, 0, Tiles.onSpawnTiles()[0])
				var AppliedBy := AppliedByGD.new()
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_HEALTH, 50))
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, 50))
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, 5))
				SpectateCamera.onSpectate(Unit)
			onStartChangePhase("HandPhase")
		"HandPhase": turns += 1
		"PlayerEndTurnPhase": onAdvanceGamePhase()
		"AIPhase": turns += 1
		"AIEndTurnPhase": onAdvanceGamePhase()
		"NeutralPhase": pass
		"NeutralEndTurnPhase": onAdvanceGamePhase()

var phase_order: Array = ["HandPhase", "PlayerPhase", "PlayerEndTurnPhase", "AIPhase", "AIEndTurnPhase", "NeutralPhase", "NeutralEndTurnPhase"]
func onAdvanceGamePhase() -> void:
	var index: int = phase_order.find(game_phase)
	if index != -1:
		if index == phase_order.size() - 1: index = 0
		else: index += 1
		onStartChangePhase(phase_order[index])

enum { # Enum for the different types of lock
	NULL_LOCK,
	HAND_LOCK, # During hand phase
	UNIT_ACTION, # When a unit is in the middle of an action
	UNIT_ACTION_DISABLE, # When a unit wishes to conclude it's actions
}

enum { # Enum for the different types of verifications
	NULL_VERIFY,
	INSPECT_UNIT,
	IN_ACTION,
	AI_PHASE,
	SPECTATE_TILE,
	HAND_EXCLUSIVE,
	TILE_HOVER,
	CHANGE_SPECTATE,
	HIGHLIGHT_OBJ,
}

var verify_lock: Dictionary = {
	NULL_VERIFY: [NULL_LOCK],
	INSPECT_UNIT: [NULL_LOCK, HAND_LOCK],
	SPECTATE_TILE: [NULL_LOCK, HAND_LOCK],
	TILE_HOVER: [NULL_LOCK, HAND_LOCK],
	CHANGE_SPECTATE: [NULL_LOCK, HAND_LOCK],
	IN_ACTION: [UNIT_ACTION],
	HAND_EXCLUSIVE: [HAND_LOCK],
	HIGHLIGHT_OBJ: [NULL_LOCK],
}
var input_lock: int = 0
signal input_lock_updated

func setInputLock(_input_lock: int = NULL_LOCK, frame_delay: bool = false) -> void:
	if _input_lock != input_lock:
		if (input_lock == UNIT_ACTION and _input_lock == UNIT_ACTION_DISABLE) or input_lock != UNIT_ACTION:
			if _input_lock == UNIT_ACTION_DISABLE: _input_lock = NULL_LOCK
			input_lock = _input_lock
			
			if frame_delay: await get_tree().process_frame
			input_lock_updated.emit()
			

func verifyLock(type: int = NULL_VERIFY) -> bool:
	return input_lock in verify_lock[type]

func on_skip_hand_phase_result(Tile: TileGD = null) -> bool:
	if game_phase == "HandPhase":
		if Settings.autopass_handphase and Hand.on_playable_cards().is_empty(): return true
		if Tiles.on_is_type_get_tiles("Spawn", "obj")\
		.all(func(x: TileGD): return x == Tile or Units.unit_by_tile_bool(x)):
			LevelUI.onHandPhaseNoSpawnTiles()
			return true
	return false

