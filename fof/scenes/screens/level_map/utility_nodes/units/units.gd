class_name UnitsGD
extends Node3D

var SpectateCamera: Camera3D
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
	return Unit

func on_start_phase_start() -> void:
	BotManager.Units = self
	PlayerManager.Units = self
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	for Tile in enemy_tiles:
		on_unit_awakened(Tile.info.obj.obj_info[0], 0, [], 1, Tile.info.obj.rotation, Tile) # add Random.on_create_random_tool() here, maybe no args and it takes from GameState

func on_player_phase_start() -> void:
	for Unit in on_units():
		Unit.speed = Unit.max_speed

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

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
				UnitSelected = Tiles.on_unit_selected(Unit)
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
		LevelMap.lock_inputs = true
		
	if !active_event.is_empty() and active_event[0] == "MoveUnit":
		SpectateCamera.position.x += active_event[1].position.x - SpectateCamera.central_point.x
		SpectateCamera.position.z += active_event[1].position.z - SpectateCamera.central_point.z
		SpectateCamera.central_point = Vector3(active_event[1].position.x, SpectateCamera.central_point.y, active_event[1].position.z)
		
func on_movement_finished(Unit: UnitGD) -> void:
	Unit.occupy_tile(active_event[2])
	active_event = []
	LevelMap.lock_inputs = false
	
