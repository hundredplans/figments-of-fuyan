class_name UnitsGD
extends Node3D

var Random: RandomGD
var Tiles: TilesGD

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	on_unit_awakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.info.obj.rotation, Tile.position)
	
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, pos: Vector3) -> UnitGD:
	var Unit: UnitGD = UnitScene.instantiate()
	add_child(Unit)
	Unit.on_create_unit(id, tool_id, effects, team, rot, pos)
	return Unit

func on_start_phase_start() -> void:
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	for Tile in enemy_tiles:
		on_unit_awakened(Tile.info.obj.obj_info[0], 0, [], 1, Tile.info.obj.rotation, Tile.position) # add Random.on_create_random_tool() here, maybe no args and it takes from GameState

func on_player_phase_start() -> void:
	pass

func on_units(team: int, relation: String) -> Array:
	return get_children().filter(on_match_team_relation.bind(team, relation))

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")
