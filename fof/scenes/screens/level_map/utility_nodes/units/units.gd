class_name UnitsGD
extends Node3D

var SpectateCamera: Camera3D
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD

@onready var BotManager: BotManagerGD = $BotManager
@onready var PlayerManager: PlayerManagerGD = $PlayerManager
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
	
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	var Unit: UnitGD = UnitScene.instantiate()
	FieldedUnits.add_child(Unit)
	Unit.on_create_unit(id, tool_id, effects, team, rot, tile)
	Vision.on_recalculate_vision()
	return Unit

func on_start_phase_start() -> void:
	BotManager.Units = self
	PlayerManager.Units = self
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	for Tile in enemy_tiles:
		on_unit_awakened(Tile.info.obj.obj_info[0], 0, [], 1, Tile.info.obj.rotation, Tile) # add Random.on_create_random_tool() here, maybe no args and it takes from GameState

func on_player_phase_start() -> void:
	pass

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
