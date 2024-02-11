class_name UnitsGD
extends Node3D

var SpectateCamera: Camera3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD

@export var UNIT_ANIMATION_BLEND_TIME: float = 0.2
@export var WALK_TRAVEL_TIME: float = 1.2

@onready var BotManager: BotManagerGD = $BotManager
@onready var PlayerManager: PlayerManagerGD = $PlayerManager
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
	
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	var Unit: UnitGD = UnitScene.instantiate()
	Unit.Units = self
	Unit.Vision = Vision
	FieldedUnits.add_child(Unit)
	Unit.on_create_unit(id, tool_id, effects, team, rot, tile)
	Unit.Model.movement_finished.connect(on_movement_finished.bind(Unit))
	LevelUI.on_add_unit_status_box(Unit)
	
	var in_vision: bool = Vision.is_unit_in_vision(Unit)
	Unit.on_arrive(team == 0 or in_vision)
	
	if team == 1 and in_vision:
		on_unit_enters_vision(Unit)
		
	return Unit

func on_start_phase_start() -> void:
	BotManager.Units = self
	PlayerManager.Units = self
	PlayerManager.LevelUI = LevelUI
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	for Tile in enemy_tiles:
		on_unit_awakened(Tile.info.obj.obj_info[0], 0, [], 1, Tile.info.obj.rotation, Tile) # add Random.on_create_random_tool() here, maybe no args and it takes from GameState

func on_player_end_turn_phase_start() -> void:
	if UnitSelected != null: _on_unit_deselected(UnitSelected, true)

func on_player_phase_start() -> void:
	for Unit in on_units():
		Unit.stats("speed", Unit.max_speed, true)

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

func all_units() -> Array:
	return FieldedUnits.get_children()

func on_units(team: int = 0, relation: String = "Ally") -> Array:
	return FieldedUnits.get_children().filter(on_match_team_relation.bind(team, relation))

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")

var UnitSelected: UnitGD
func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = unit_by_tile(Tile)
	if Unit.team == 0:
		match LevelMap.game_phase:
			"PlayerPhase":
				on_unit_selected(Unit)
	else:
		pass

var active_event: Array
var move_queue: Array

func move_to_tile(Unit: UnitGD, Tile: TileGD) -> void:
	move_queue.append([Unit, Tile])
	
func _process(_delta: float) -> void:
	if !move_queue.is_empty() and active_event.is_empty():
		active_event = ["MoveUnit"] + move_queue.pop_front()
		active_event[1].Model.move_to_tile(active_event[2])
		LevelMap.set_lock_inputs(true)
		
	if !active_event.is_empty() and active_event[0] == "MoveUnit":
		SpectateCamera.position.x += active_event[1].position.x - SpectateCamera.central_point.x
		SpectateCamera.position.z += active_event[1].position.z - SpectateCamera.central_point.z
		SpectateCamera.central_point = Vector3(active_event[1].position.x, SpectateCamera.central_point.y, active_event[1].position.z)
		
func on_movement_finished(Unit: UnitGD) -> void:
	Unit.stats("speed", -1)
	Unit.occupy_tile(active_event[2])
	if move_queue.is_empty(): on_empty_move_queue()
	else:
		Unit.Model.on_play_walk_sfx()
		active_event = []
	
func on_unit_selected(Unit: UnitGD) -> void:
	if UnitSelected == Unit:
		_on_unit_deselected(Unit)
	elif UnitSelected != null:
		_on_unit_deselected(UnitSelected)
		if Unit.speed > 0:
			_on_unit_selected(Unit)
	elif Unit.speed > 0: _on_unit_selected(Unit)

func _on_unit_deselected(Unit: UnitGD, absolute: bool = false) -> void:
	Tiles.on_set_tile_material(UnitSelected.Tile, "", absolute)
	for Tile in Tiles.tiles_in_speed(UnitSelected):
		Tiles.on_set_tile_material(Tile, "", absolute)
	if Unit == UnitSelected: UnitSelected = null
	
func _on_unit_selected(Unit: UnitGD) -> void:
	Tiles.on_set_tile_material(Unit.Tile, "UnitSelected")
	for Tile in Tiles.tiles_in_speed(Unit):
		Tiles.on_set_tile_material(Tile, "MovementRange")
	if UnitSelected == null: UnitSelected = Unit

func on_unit_enters_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_enters_vision(Unit)
		
func on_unit_exits_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_exits_vision(Unit)

func on_empty_move_queue() -> void:
	on_force_resume_idle_animation_from_walk()
	active_event = []
	move_queue = []
	LevelMap.set_lock_inputs(false)
	
func on_force_resume_idle_animation_from_walk() -> void:
	if active_event.size() > 0 and active_event[0] == "MoveUnit":
		active_event[1].Model.on_play_animation("Idle")
		if active_event[1].Model.current_walk_stream_player != null:
			AudioMaster.on_cutoff_sfx(active_event[1].Model.current_walk_stream_player)
